#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <libaio.h>
#include "data_types.h"

#define uint64 uint64_t

typedef enum {
	ft_unknown, ft_fasta, ft_fastq
} FileType;

class AIO_Parser{
public:
    AIO_Parser(std::string FileName, uint64 buffer_size, long _f_start, long f_end, uint32_t shard_idx){
        this->fp = open(FileName.c_str(), O_RDONLY | O_NONBLOCK | O_DIRECT);
        if (lseek(this->fp, _f_start, SEEK_SET) == -1) printf("Cannot move fp\n");

        this->file_size = f_end - _f_start;
        this->BufferSize = buffer_size;
        
        posix_memalign((void**)&this->in_buffer[0], getpagesize(), this->BufferSize); 
		posix_memalign((void**)&this->in_buffer[1], getpagesize(), this->BufferSize); 
        
        this->f_start = _f_start;
        
        this->buffer = NULL;
        this->out_buffer = (char*) malloc(BufferSize + KMER_DATA_LENGTH);

        this->next_cur = this->cur = this->buffer;
        this->FIND_NEXT_HEADER = true;
        this->END_OF_FILE = false;
        this->OUTPUT_BUFFER_FULL = false;
        this->offset = 0;
        this->total_read_size = 0;
        this->shard_idx = shard_idx;

        std::string extFasta(".fasta");
        std::string extFastq(".fastq");
        std::string extFna(".fna");
        if (FileName.compare(FileName.size() - extFasta.size(), extFasta.size(), extFasta) == 0)
            this->_FileType = ft_fasta;
        else if (FileName.compare(FileName.size() - extFastq.size(), extFastq.size(), extFastq) == 0)
            this->_FileType = ft_fastq;
        else if (FileName.compare(FileName.size() - extFna.size(), extFna.size(), extFna) == 0)
            this->_FileType = ft_fasta;
        else{
            this->_FileType = ft_unknown;
            printf("Unable to resolve the File Extension\n");
        }
    }

    uint64 get_next(){
        if (this->total_read_size == 0){
            this->total_read_size = read(this->fp, this->in_buffer[0], this->BufferSize);
	        if(this->total_read_size < this->BufferSize){
		        this->END_OF_FILE = true;
                this->BufferSize = this->total_read_size;
		    }
	        else{
                memset(&this->ctx, 0, sizeof(this->ctx));	
	            memset(&this->cb, 0, sizeof(this->cb));	
		        this->iocbs = &this->cb;
                this->f_start += this->total_read_size;
                if(io_setup(1, &this->ctx) < 0) {	
                    printf("io_setup error\n");	
	            }	
		        io_prep_pread(&this->cb, this->fp, this->in_buffer[1], this->BufferSize, this->f_start);
		        if(io_submit(this->ctx, 1, &this->iocbs) < 0){
			        printf("io_submit error\n");
		        }
                this->_buffer_cur = 0;
	        }
            this->buffer = this->in_buffer[this->_buffer_cur];
            this->cur = this->buffer;
            this->FIND_NEXT_HEADER = false;
            if(this-> shard_idx == 0){
                skip_line();
            }
            else{
                find_next_headerline();
                skip_line();
            }
            return parse_data();
        }

        else if (this->next_cur - this->buffer < this->BufferSize){ //looking for the next seq in this buffer, no need to read from the file
            if(this->total_read_size - (this->BufferSize + this->buffer - this->cur) >= this->file_size)
                return 0;
            
            this->offset = 0;
            this->FIND_NEXT_HEADER = true; //This is the end of a seq, need to find the next seq header 
            return parse_data();
        }
        else{ // END of the reading buffer is a seq
            if(this->END_OF_FILE)
                return 0;
            if(this->offset >= KMER_DATA_LENGTH){ //C
                memmove(this->out_buffer, this->out_buffer + this->offset - KMER_DATA_LENGTH + 1, KMER_DATA_LENGTH - 1);
                this->offset = KMER_DATA_LENGTH-1;
            }
            
            if (read_into_buffer() == 0) return 0;

            this->FIND_NEXT_HEADER = false;
            this->cur = this->buffer;
            //TODO: Difference kmers between 4MB and 16MB buffer
            // + at the end of the quality line
            //Corner case: +/n@ : During split, if the last symbol is +, will have to process the next sequence
            return parse_data();
        }
        

    }

    int read_into_buffer(){
        if(this->END_OF_FILE) return 0;

        while(io_getevents(this->ctx, 0, 1, this->events, NULL) != 1) printf("io_getevents error\n");
        //io_getevents(this->ctx, 1, 1, this->events, NULL);
		int read_size = this->events[0].res;
		this->f_start += read_size;
		
		memset(&this->ctx, 0, sizeof(this->ctx));
		memset(&this->cb, 0, sizeof(this->cb));	
		io_setup(1, &this->ctx);	
			
		io_prep_pread(&this->cb, this->fp, this->in_buffer[this->_buffer_cur], this->BufferSize, this->f_start);	
        this->_buffer_cur = 1 - this->_buffer_cur;
		this->buffer= this->in_buffer[this->_buffer_cur];	
			
		if(io_submit(this->ctx, 1, &this->iocbs) < 0){
			printf("io_setup error\n");	\
		}
        
        this->total_read_size += read_size;
        if(this->BufferSize != read_size){
            this->END_OF_FILE = true;
            this->BufferSize = read_size;
            //cout << "END OF FILE"<< endl;
        }   
        this->cur = this->next_cur = this->buffer;
        return read_size;
    }

    uint64 parse_data(){
        if (this->_FileType == ft_fasta){
            if(this->FIND_NEXT_HEADER){
                if (find_next_headerline() == -1) return 0;
                if (skip_line() == -1) return 0;
      
            }
    
            this->next_cur = this->cur;
            
            while(this->next_cur < this->buffer + this->BufferSize && *this->next_cur != '>'){
                
                while(this->next_cur < this->buffer + this->BufferSize && *this->next_cur != '\n'){
                    ++this->next_cur;
                    //cout << *next_cur;
                }
                
                memcpy(this->out_buffer+this->offset, this->cur, this->next_cur - this->cur);
                this->offset += (this->next_cur - this->cur);

                if(this->next_cur < this->buffer + this->BufferSize)
                    this->next_cur ++;
                this->cur = this->next_cur;
            }
            if(this->offset == 0){ //happens when the end of the buffer is a header
               this->FIND_NEXT_HEADER = true;
               return parse_data();
            }
            return this->offset;
        }

        else if (this->_FileType == ft_fastq){
            /*if(this->FIND_NEXT_HEADER){
                if (find_next_headerline() == -1) return 0;
                if (skip_line() == -1) return 0;
      
            }*/
            this->next_cur = this->cur;

            while(this->next_cur < this->buffer + this->BufferSize && *this->next_cur != '+'){
                
                while(this->next_cur < this->buffer + this->BufferSize && *this->next_cur != '\n'){
                    ++this->next_cur;
                    //cout << *next_cur;
                }
                
                memcpy(this->out_buffer+this->offset, this->cur, this->next_cur - this->cur);
                this->offset += (this->next_cur - this->cur);

                if(this->next_cur < this->buffer + this->BufferSize)
                    this->next_cur ++;
                this->cur = this->next_cur;
            }

           
            if(*this->cur == '+'){
                skip_line();
                skip_line();
                //if (*this->cur != '@') cout << "not @" << endl;
                skip_line();
            }

                

            if(this->offset == 0){ //happens when the end of the buffer is /n (header)
                if (read_into_buffer() == 0) return 0;
                return parse_data();
            }
            return this->offset;
            
        }

        else
            return 0;
    }

    int skip_line(){
        while (*this->cur != '\n' && this->cur < this->buffer+this->BufferSize)
            ++this->cur;
            
        while(this->cur == this->buffer+this->BufferSize){
            if (*this->cur == '\n'){
                if (read_into_buffer() == 0) return -1;
                return 0;
            }      
            if (read_into_buffer() == 0) return -1;
            //if(total_read_size >= file_size || END_OF_FILE)
                //return;
            // this->cur = this->buffer;
            while (*this->cur != '\n' && this->cur < this->buffer+this->BufferSize)
                ++this->cur;
        }
        ++this->cur; //cur now is the first char in the new line
        return 0;
    }

    int find_next_headerline(){
        if(this->_FileType == ft_fasta){
            while (*this->cur != '>' && this->cur < this->buffer+this->BufferSize)
                ++this->cur;
            if (*this->cur == '\n' && this->cur == this->buffer+this->BufferSize){
                if (read_into_buffer() == 0) return -1;
                return 0;
            }
            while(this->cur == this->buffer + this->BufferSize){
                if(read_into_buffer() == 0) return -1;
                //if(total_read_size >= file_size || END_OF_FILE)
                    //return;
                this->cur = this->buffer;
                while (*this->cur != '>' && this->cur < this->buffer+this->BufferSize)
                    ++this->cur;   
            }
            return 0;
        }
        if(this->_FileType == ft_fastq){
            /*while (*this->cur != '@' && this->cur < this->buffer+this->BufferSize){
                ++this->cur;
            }*/
            
            
            //TODO: What if \n and @ are located on the boudary
            while (this->cur < this->buffer+this->BufferSize){
                if(*this->cur == '\n' && *(this->cur+1) == '@'){ //&& (this->cur > this->buffer) && *(this->cur-1)!='+'){
                    this->cur += 2;
                    return 0;
                }
                ++this->cur;
            }

            /*TODO: What if \n and @ are located on the boudary
            if (*this->cur == '\n' && this->cur == this->buffer+this->BufferSize){
                if (read_into_buffer() == 0) return -1;
                return 0;
            }*/

            //End of the buffer, still not find the next header
            while(this->cur == this->buffer + this->BufferSize){
                if(*this->cur == '\n'){
                    if(*(this->cur-1) != '+'){
                        if(read_into_buffer() == 0) return -1;
                        if(*this->cur == '@'){
                            this->cur ++;
                            return 0;
                        }
                    }
                }
                else if((*this->cur == '@') && (*this->cur-1) == '\n'){
                    if(*(this->cur-2) != '+'){
                        if(read_into_buffer() == 0) return -1;
                        return 0;
                    }
                }
                else{
                    if(read_into_buffer() == 0) return -1;
                }
                //if(total_read_size >= file_size || END_OF_FILE)
                    //return;
                while (this->cur < this->buffer+this->BufferSize){
                    if(*this->cur == '\n' && *(this->cur+1) == '@'){ //&& (this->cur > this->buffer) && *(this->cur-1)!='+'){
                        this->cur += 2;
                        return 0;
                    }
                    ++this->cur;
                }
            }
            return 0;
        }
        return 0;
    }

    

    ~AIO_Parser(){
        close(this -> fp);
        free(this -> in_buffer[0]);
        free(this ->in_buffer[1]);
        free(this -> out_buffer);
        io_destroy(this -> ctx);
    }

    int fp;
    char* buffer;
    char* out_buffer;
    char* cur;
    char* next_cur;
    uint64 BufferSize, total_read_size, file_size;
    FileType _FileType;
    bool END_OF_FILE, FIND_NEXT_HEADER, OUTPUT_BUFFER_FULL;
    uint64 offset;
    char* in_buffer[2];
    int _buffer_cur;
    struct iocb cb;	
	struct iocb* iocbs;	
	struct io_event events[1];	
	io_context_t ctx;	
    long f_start;
    uint32_t shard_idx;
};


class FastParser{
public:
    FastParser(std::string FileName, uint64 buffer_size, long f_start, long f_end, uint32_t shard_idx){
        this->fp = fopen(FileName.c_str(), "rb");
        if (fseek(this->fp, f_start, SEEK_SET) == -1) printf("Cannot move fp");
        this->file_size = f_end - f_start;
        setbuf(fp, NULL); //Disable buffering
        this->BufferSize = buffer_size;
        this->buffer = (char*) malloc(this->BufferSize);
        this->out_buffer = (char*) malloc(this->BufferSize + KMER_DATA_LENGTH);

        this->next_cur = this->cur = this->buffer;
        this->FIND_NEXT_HEADER = true;
        this->END_OF_FILE = false;
        this->OUTPUT_BUFFER_FULL = false;
        this->offset = 0;
        this->total_read_size = 0;
        this->shard_idx = shard_idx;

        std::string extFasta(".fasta");
        std::string extFastq(".fastq");
        std::string extFna(".fna");
        if (FileName.compare(FileName.size() - extFasta.size(), extFasta.size(), extFasta) == 0)
            this->_FileType = ft_fasta;
        else if (FileName.compare(FileName.size() - extFastq.size(), extFastq.size(), extFastq) == 0)
            this->_FileType = ft_fastq;
        else if (FileName.compare(FileName.size() - extFna.size(), extFna.size(), extFna) == 0)
            this->_FileType = ft_fasta;
        else{
            this->_FileType = ft_unknown;
            printf("Unable to resolve the File Extension\n");
        }
    }

    uint64 get_next(){
        if (this->total_read_size == 0){
            read_into_buffer();
            this->cur = this->buffer;
            return parse_data();
        }

        else if (this->next_cur - this->buffer < this->BufferSize){ //looking for the next seq in this buffer, no need to read from the file
            if(this->total_read_size - (this->BufferSize + this->buffer - this->cur) >= this->file_size){
                printf("End of thread\n");
                return 0;
            }

            this->offset = 0;
            this->FIND_NEXT_HEADER = true; //This is the end of a seq, need to find the next seq header 
            return parse_data();
        }
        else{
            if(this->END_OF_FILE){
                return 0;
            }
            if(this->offset >= KMER_DATA_LENGTH){
                memmove(this->out_buffer, this->out_buffer + this->offset - KMER_DATA_LENGTH + 1, KMER_DATA_LENGTH - 1);
                this->offset = KMER_DATA_LENGTH-1;
            }

            if (read_into_buffer() == 0) return 0;

            this->FIND_NEXT_HEADER = false;
            this->cur = this->buffer;
            return parse_data();
        }
        

    }

    int read_into_buffer(){
        if(this->END_OF_FILE) return 0;
        //read_cnt += 1;
        int read_size = fread(this->buffer, 1, this->BufferSize, this->fp);
        this->total_read_size += read_size;
        if(read_size != this->BufferSize){
            this->END_OF_FILE = true;
            this->BufferSize = read_size;
        }   
        this->cur = this->next_cur = this->buffer;
        return read_size;
    }

     uint64 parse_data(){
        if (this->_FileType == ft_fasta){
            if(this->FIND_NEXT_HEADER){
                if (find_next_headerline() == -1) return 0;
                if (skip_line() == -1) return 0;
      
            }
    
            this->next_cur = this->cur;
            
            while(this->next_cur < this->buffer + this->BufferSize && *this->next_cur != '>'){
                
                while(this->next_cur < this->buffer + this->BufferSize && *this->next_cur != '\n'){
                    ++this->next_cur;
                    //cout << *next_cur;
                }
                
                memcpy(this->out_buffer+this->offset, this->cur, this->next_cur - this->cur);
                this->offset += (this->next_cur - this->cur);

                if(this->next_cur < this->buffer + this->BufferSize)
                    this->next_cur ++;
                this->cur = this->next_cur;
            }
            if(this->offset == 0){ //happens when the end of the buffer is a header
               this->FIND_NEXT_HEADER = true;
               return parse_data();
            }
            return this->offset;
        }

        else if (this->_FileType == ft_fastq){
            if(this->FIND_NEXT_HEADER){
                if (find_next_headerline() == -1) return 0;
                if (skip_line() == -1) return 0;
      
            }
            this->next_cur = this->cur;
            
            while(this->next_cur < this->buffer + this->BufferSize && *this->next_cur != '+'){
                
                while(this->next_cur < this->buffer + this->BufferSize && *this->next_cur != '\n'){
                    ++this->next_cur;
                    //cout << *next_cur;
                }
                
                memcpy(this->out_buffer+this->offset, this->cur, this->next_cur - this->cur);
                this->offset += (this->next_cur - this->cur);

                if(this->next_cur < this->buffer + this->BufferSize)
                    this->next_cur ++;
                this->cur = this->next_cur;
            }
            skip_line();
            skip_line();

            if(this->offset == 0){ //happens when the end of the buffer is a header
               this->FIND_NEXT_HEADER = true;
               return parse_data();
            }
            return this->offset;
            
        }

        else
            return 0;
    }

    int skip_line(){
        while (*this->cur != '\n' && this->cur < this->buffer+this->BufferSize)
            ++this->cur;
        while(this->cur >= this->buffer+this->BufferSize - 1){
            if (*this->cur == '\n'){
                if (read_into_buffer() == 0) return -1;
                return 0;
            }   
            if (read_into_buffer() == 0) return -1;
            //if(total_read_size >= file_size || END_OF_FILE)
                //return;
            this->cur = this->buffer;
            while (*this->cur != '\n' && this->cur < this->buffer+this->BufferSize)
                ++this->cur;
        }
        ++this->cur; //cur now is the first char in the new line
        return 0;
    }

    int find_next_headerline(){
        if(this->_FileType == ft_fasta){
            while (*this->cur != '>' && this->cur < this->buffer+this->BufferSize)
                ++this->cur;
            if (*this->cur == '\n' && this->cur == this->buffer+this->BufferSize){
                if (read_into_buffer() == 0) return -1;
                return 0;
            }
            while(this->cur == this->buffer + this->BufferSize){
                if(read_into_buffer() == 0) return -1;
                //if(total_read_size >= file_size || END_OF_FILE)
                    //return;
                this->cur = this->buffer;
                while (*this->cur != '>' && this->cur < this->buffer+this->BufferSize)
                    ++this->cur;   
            }
            return 0;
        }
        if(this->_FileType == ft_fastq){
            while (*this->cur != '@' && this->cur < this->buffer+this->BufferSize){
                ++this->cur;
            }
            return 0;
            //TODO: What if \n and @ are located on the boudary
            while (this->cur < this->buffer+this->BufferSize){
                if(*this->cur == '\n' && *(this->cur+1) == '@'){
                    this->cur += 2;
                    return 0;
                }
                ++this->cur;
            }
            //TODO: What if \n and @ are located on the boudary
            if (*this->cur == '\n' && this->cur == this->buffer+this->BufferSize){
                if (read_into_buffer() == 0) return -1;
                return 0;
            }

            //End of the buffer, still not find the next header
            while(this->cur == this->buffer + this->BufferSize){
                if(read_into_buffer() == 0) return -1;
                //if(total_read_size >= file_size || END_OF_FILE)
                    //return;
                this->cur = this->buffer;
                while (this->cur < this->buffer+this->BufferSize){
                    if(*this->cur == '\n' && *(this->cur+1) == '@'){
                        this->cur += 2;
                        return 0;
                    }
                    ++this->cur;
                }
            }
            return 0;
        }
        return 0;
    }

    /*bool begin_with_header(){
        char* p = this -> buffer;
        for(int i = 0; i < 100; i++){
            if(*(p + i) == '>') return false
        }
    }*/


    ~FastParser(){
        fclose(this->fp);
        free(this->buffer);
        free(this->out_buffer);
    }

    FILE* fp;
    char* buffer;
    char* out_buffer;
    char* cur;
    char* next_cur;
    uint64 BufferSize, total_read_size, file_size;
    FileType _FileType;
    bool END_OF_FILE, FIND_NEXT_HEADER, OUTPUT_BUFFER_FULL;
    uint64 offset;
    uint32_t shard_idx;
    //int read_cnt;
};
