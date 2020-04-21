#include <string.h>
#include <stdlib.h>
#include <stdio.h>
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
        //cout << total_read_size << " " << file_size << " " << next_cur - buffer << " " << BUFFER_SIZE << endl;
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
            //cout << total_read_size << " " << (BUFFER_SIZE + buffer -cur) << " " << buffer -cur << " " << END_OF_FILE << endl;
            offset = 0;
            //cur = next_cur;
            FIND_NEXT_HEADER = true; //This is the end of a seq, need to find the next seq header 
            return parse_data(kseq_begin);
        }
        else{
            //memcpy(boundary_buf, buffer + BUFFER_SIZE - KMER_DATA_LENGTH, KMER_DATA_LENGTH - 1)
            if(END_OF_FILE)
                return 0;
            //cout << "!!!!!!!!!!!!!!!!!!!!!" << endl;
            if(offset > KMER_DATA_LENGTH){
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

        int read_size = fread(buffer+offset, 1, size, fp);
        total_read_size += read_size;
        //cout << "Read: " << size << " " << read_size << endl;
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
        //cout << cur - buffer << endl;
    }


    ~FASTAParser(){
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


};