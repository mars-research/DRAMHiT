#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <libaio.h>
#include "data_types.h"

typedef enum {
	ft_unknown, ft_fasta, ft_fastq
} FileType;

class FASTAParser{
public:
    FASTAParser(std::string FileName, uint64 buffer_size, long f_start, long f_end){
        //fp = open(config.in_file.c_str(), O_RDONLY | O_NONBLOCK | O_DIRECT);
        fp = fopen(FileName.c_str(), "rb");
        if (fseek(fp, f_start, SEEK_SET) == -1) printf("Cannot move fp");

        file_size = f_end - f_start;
        setbuf(fp, NULL); //Disable buffering
        BUFFER_SIZE = buffer_size;
        buffer = (char*) malloc(BUFFER_SIZE);
        out_buffer = (char*) malloc(BUFFER_SIZE + KMER_DATA_LENGTH);

        next_cur = cur = buffer;
        FIND_NEXT_HEADER = true;
        END_OF_FILE = false;
        OUTPUT_BUFFER_FULL = false;
        offset = 0;
        total_read_size = 0;
        if (fseek(fp, f_start, SEEK_SET) == -1) printf("Cannot move fp");
        file_size = f_end - f_start;
        // read_cnt = 0;
        std::string extFasta(".fasta");
        std::string extFastq(".fastq");
        std::string extFna(".fna");
        if (FileName.compare(FileName.size() - extFasta.size(), extFasta.size(), extFasta) == 0)
            _FileType = ft_fasta;
        else if (FileName.compare(FileName.size() - extFastq.size(), extFastq.size(), extFastq) == 0)
            _FileType = ft_fastq;
        else if (FileName.compare(FileName.size() - extFna.size(), extFna.size(), extFna) == 0)
            _FileType = ft_fasta;
        else{
            _FileType = ft_unknown;
            printf("Unable to resolve the File Extension\n");
        }
    }

    uint64 get_next(char* & kseq_begin){
        //memset(out_buffer, BUFFER_SIZE + KMER_DATA_LENGTH, 0);
        if (total_read_size == 0){
            read_into_buffer(0, BUFFER_SIZE);
            cur = buffer;
            return parse_data(kseq_begin);
        }

        /*else if (OUTPUT_BUFFER_FULL){
            memmove(out_buffer, out_buffer+BUFFER_SIZE-KMER_DATA_LENGTH+1, KMER_DATA_LENGTH-1);
            memcpy
        }*/

        else if (next_cur - buffer < BUFFER_SIZE){ //looking for the next seq in this buffer, no need to read from the file
            if(total_read_size - (BUFFER_SIZE + buffer -cur) >= file_size)
                return 0;
            offset = 0;
            //cur = next_cur;
            FIND_NEXT_HEADER = true; //This is the end of a seq, need to find the next seq header 
            return parse_data(kseq_begin);
        }
        else{
            //memcpy(boundary_buf, buffer + BUFFER_SIZE - KMER_DATA_LENGTH, KMER_DATA_LENGTH - 1)
            //cout << "Read here" << endl;
            if(END_OF_FILE)
                return 0;
            if(offset >= KMER_DATA_LENGTH){
                memmove(out_buffer, out_buffer + offset - KMER_DATA_LENGTH + 1, KMER_DATA_LENGTH - 1);
                //memcpy(out_buffer, buffer, KMER_DATA_LENGTH-1);
                offset = KMER_DATA_LENGTH-1;
            }

            
            //memmove(buffer, buffer + BUFFER_SIZE - KMER_DATA_LENGTH, KMER_DATA_LENGTH - 1);
            if (read_into_buffer(0, BUFFER_SIZE) == 0) return 0;

            //memcpy(boundary_buf + KMER_DATA_LENGTH - 1, buffer, KMER_DATA_LENGTH - 1);
            FIND_NEXT_HEADER = false;
            cur = buffer;
            return parse_data(kseq_begin);
        }
        

    }



    int read_into_buffer(int offset, int size){
        if(END_OF_FILE) return 0;
        //read_cnt += 1;
        int read_size = fread(buffer+offset, 1, size, fp);
        total_read_size += read_size;
        if(size != read_size){
            END_OF_FILE = true;
            BUFFER_SIZE = read_size;
        }   
        cur = next_cur = buffer;
        
        return read_size;
    }

    uint64 parse_data(char* & kseq_begin){
        if (_FileType == ft_fasta){
            if(FIND_NEXT_HEADER){
                if (find_next_headerline() == -1) return 0;
                if (skip_line() == -1) return 0;
                // if(total_read_size >= file_size || END_OF_FILE)
                //    return 0;
            }
            next_cur = cur;
            
            while(next_cur < buffer + BUFFER_SIZE && *next_cur != '>'){
                
                while(next_cur < buffer + BUFFER_SIZE && *next_cur != '\n'){
                    ++next_cur;
                    //cout << *next_cur;
                }
                
                memcpy(out_buffer+offset, cur, next_cur - cur);
                offset += (next_cur - cur);

                if(next_cur < buffer + BUFFER_SIZE)
                    next_cur ++;
                cur = next_cur;
            }
            kseq_begin = out_buffer;
            return offset;
        }
        else if (_FileType == ft_fastq){
            //TODO
        }

        else
            return 0;
    }

    int skip_line(){
        //cout << cur - buffer << endl;
        while (*cur != '\n' && cur < buffer+BUFFER_SIZE)
            ++cur;
        while(cur == buffer+BUFFER_SIZE){
            //cout << "skip" << endl;
            if (read_into_buffer(0, BUFFER_SIZE) == 0) return -1;
            //if(total_read_size >= file_size || END_OF_FILE)
                //return;
            cur = buffer;
            while (*cur != '\n' && cur < buffer+BUFFER_SIZE)
                ++cur;
        }
        ++cur;
        return 0;
    }

    int find_next_headerline(){
        while (*cur != '>' && cur < buffer+BUFFER_SIZE)
            ++cur;
        while(cur == buffer+BUFFER_SIZE){
            //cout << "find" << endl;
            if(read_into_buffer(0, BUFFER_SIZE) == 0) return -1;
            //if(total_read_size >= file_size || END_OF_FILE)
                //return;
            cur = buffer;
            while (*cur != '>' && cur < buffer+BUFFER_SIZE)
                ++cur;   
        }
        return 0;
        //cout << cur - buffer << endl;
    }


    ~FASTAParser(){
        fclose(fp);
        free(buffer);
        free(out_buffer);
    }

    FILE* fp;
    char* buffer;
    char* out_buffer;
    char* cur;
    char* next_cur;
    uint64 BUFFER_SIZE, total_read_size, file_size;
    FileType _FileType;
    bool END_OF_FILE, FIND_NEXT_HEADER, OUTPUT_BUFFER_FULL;
    uint64 offset;
    //int read_cnt;

};



class AIO_FASTAParser{
public:
    AIO_FASTAParser(std::string FileName, uint64 buffer_size, long _f_start, long f_end){
        fp = open(config.in_file.c_str(), O_RDONLY | O_NONBLOCK | O_DIRECT);
        if (lseek(fp, _f_start, SEEK_SET) == -1) printf("Cannot move fp");

        file_size = f_end - _f_start;
        BUFFER_SIZE = buffer_size;
        
        posix_memalign((void**)&in_buffer[0], getpagesize(), BUFFER_SIZE); \
		posix_memalign((void**)&in_buffer[1], getpagesize(), BUFFER_SIZE); \
        
        f_start = _f_start;
        
        buffer = NULL;
        out_buffer = (char*) malloc(BUFFER_SIZE + KMER_DATA_LENGTH);

        next_cur = cur = buffer;
        FIND_NEXT_HEADER = true;
        END_OF_FILE = false;
        OUTPUT_BUFFER_FULL = false;
        offset = 0;
        total_read_size = 0;
        file_size = f_end - _f_start;

        std::string extFasta(".fasta");
        std::string extFastq(".fastq");
        std::string extFna(".fna");
        if (FileName.compare(FileName.size() - extFasta.size(), extFasta.size(), extFasta) == 0)
            _FileType = ft_fasta;
        else if (FileName.compare(FileName.size() - extFastq.size(), extFastq.size(), extFastq) == 0)
            _FileType = ft_fastq;
        else if (FileName.compare(FileName.size() - extFna.size(), extFna.size(), extFna) == 0)
            _FileType = ft_fasta;
        else{
            _FileType = ft_unknown;
            printf("Unable to resolve the File Extension\n");
        }
    }

    uint64 get_next(char* & kseq_begin){
        //memset(out_buffer, BUFFER_SIZE + KMER_DATA_LENGTH, 0);
        if (total_read_size == 0){
            //read_into_buffer(0, BUFFER_SIZE);
            total_read_size = read(fp, in_buffer[0], BUFFER_SIZE);
            memset(&ctx, 0, sizeof(ctx));	
	        memset(&cb, 0, sizeof(cb));	
		    iocbs = &cb;
            f_start += 	total_read_size;
            if(io_setup(1, &ctx) < 0) {	
                printf("io_setup error\n");	
	        }	
		    io_prep_pread(&cb, fp, in_buffer[1], BUFFER_SIZE, f_start);
		    if(io_submit(ctx, 1, &iocbs) < 0){
			    printf("io_submit error\n");
		    }
            _buffer_cur = 0;
            buffer = in_buffer[_buffer_cur];
            cur = buffer;
            return parse_data(kseq_begin);
        }

        /*else if (OUTPUT_BUFFER_FULL){
            memmove(out_buffer, out_buffer+BUFFER_SIZE-KMER_DATA_LENGTH+1, KMER_DATA_LENGTH-1);
            memcpy
        }*/

        else if (next_cur - buffer < BUFFER_SIZE){ //looking for the next seq in this buffer, no need to read from the file
            if(total_read_size - (BUFFER_SIZE + buffer -cur) >= file_size)
                return 0;
            offset = 0;
            //cur = next_cur;
            FIND_NEXT_HEADER = true; //This is the end of a seq, need to find the next seq header 
            return parse_data(kseq_begin);
        }
        else{
            //cout << "Read here" << endl;
            //memcpy(boundary_buf, buffer + BUFFER_SIZE - KMER_DATA_LENGTH, KMER_DATA_LENGTH - 1)
            if(END_OF_FILE)
                return 0;
            if(offset >= KMER_DATA_LENGTH){
                memmove(out_buffer, out_buffer + offset - KMER_DATA_LENGTH + 1, KMER_DATA_LENGTH - 1);
                //memcpy(out_buffer, buffer, KMER_DATA_LENGTH-1);
                offset = KMER_DATA_LENGTH-1;
            }
            
            //memmove(buffer, buffer + BUFFER_SIZE - KMER_DATA_LENGTH, KMER_DATA_LENGTH - 1);
            if (read_into_buffer(0, BUFFER_SIZE) == 0) return 0;

            //memcpy(boundary_buf + KMER_DATA_LENGTH - 1, buffer, KMER_DATA_LENGTH - 1);
            FIND_NEXT_HEADER = false;
            cur = buffer;
            return parse_data(kseq_begin);
        }
        

    }



    int read_into_buffer(int offset, int size){
        if(END_OF_FILE) return 0;

        while(io_getevents(ctx, 0, 1, events, NULL) != 1) printf("io_getevents error\n");
		int read_size = events[0].res;
		f_start += read_size;
		
		memset(&ctx, 0, sizeof(ctx));
		memset(&cb, 0, sizeof(cb));	
		io_setup(1, &ctx);	
			
		io_prep_pread(&cb, fp, in_buffer[_buffer_cur], BUFFER_SIZE, f_start);	
        _buffer_cur = 1 - _buffer_cur;
		buffer= in_buffer[_buffer_cur];	
			
		if(io_submit(ctx, 1, &iocbs) < 0){
			printf("io_setup error\n");	\
		}
        
        //int read_size = fread(buffer+offset, 1, size, fp);
        total_read_size += read_size;
        if(size != read_size){
            END_OF_FILE = true;
            BUFFER_SIZE = read_size;
        }   
        cur = next_cur = buffer;
        return read_size;
    }

    uint64 parse_data(char* & kseq_begin){
        if (_FileType == ft_fasta){
            if(FIND_NEXT_HEADER){
                if (find_next_headerline() == -1) return 0;
                if (skip_line() == -1) return 0;
                // if(total_read_size >= file_size || END_OF_FILE)
                //    return 0;
            }
            next_cur = cur;
            
            while(next_cur < buffer + BUFFER_SIZE && *next_cur != '>'){
                
                while(next_cur < buffer + BUFFER_SIZE && *next_cur != '\n'){
                    ++next_cur;
                    //cout << *next_cur;
                }
                
                memcpy(out_buffer+offset, cur, next_cur - cur);
                offset += (next_cur - cur);

                if(next_cur < buffer + BUFFER_SIZE)
                    next_cur ++;
                cur = next_cur;
            }
            //cout << "return: " << offset << endl;
            kseq_begin = out_buffer;
            return offset;
        }
        else if (_FileType == ft_fastq){
            //TODO
        }

        else
            return 0;
    }

    int skip_line(){
        //cout << cur - buffer << endl;
        while (*cur != '\n' && cur < buffer+BUFFER_SIZE)
            ++cur;
        while(cur == buffer+BUFFER_SIZE){
            if (read_into_buffer(0, BUFFER_SIZE) == 0) return -1;
            //if(total_read_size >= file_size || END_OF_FILE)
                //return;
            cur = buffer;
            while (*cur != '\n' && cur < buffer+BUFFER_SIZE)
                ++cur;
        }
        ++cur;
        return 0;
    }

    int find_next_headerline(){
        while (*cur != '>' && cur < buffer+BUFFER_SIZE)
            ++cur;
        while(cur == buffer+BUFFER_SIZE){
            if(read_into_buffer(0, BUFFER_SIZE) == 0) return -1;
            //if(total_read_size >= file_size || END_OF_FILE)
                //return;
            cur = buffer;
            while (*cur != '>' && cur < buffer+BUFFER_SIZE)
                ++cur;   
        }
        return 0;
    }


    ~AIO_FASTAParser(){
        close(fp);
        free(in_buffer[0]);
        free(in_buffer[1]);
        free(out_buffer);
        io_destroy(ctx);
    }

    int fp;
    char* buffer;
    char* out_buffer;
    char* cur;
    char* next_cur;
    uint64 BUFFER_SIZE, total_read_size, file_size;
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

};