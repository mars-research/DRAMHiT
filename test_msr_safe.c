// msr_safe_read.c
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

char const *const allowlist = "0x1A4 0xFFFFFFFFFFFFFFFF\n";  // MPERF

void set_allowlist()
{
    int fd = open("/dev/cpu/msr_allowlist", O_WRONLY);
    if(-1 == fd){
        printf("bad\n"); 
    }
    ssize_t nbytes = write(fd, allowlist, strlen(allowlist));
    if(strlen(allowlist) != nbytes){
printf("bad\n"); 
    }
    close(fd);
}


int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <cpu> <msr-hex>\n", argv[0]);
        return 1;
    }

    set_allowlist();

    int cpu = atoi(argv[1]);
    unsigned long msr = strtoul(argv[2], NULL, 0);

    char path[64];
    snprintf(path, sizeof(path), "/dev/cpu/%d/msr_safe", cpu);

    int fd = open(path, O_RDONLY);
    if (fd < 0) {
        fprintf(stderr, "Error opening %s: %s\n", path, strerror(errno));
        return 1;
    }

    uint64_t val;
    ssize_t rc = pread(fd, &val, sizeof(val), msr);
    if (rc != sizeof(val)) {
        fprintf(stderr, "pread failed for MSR 0x%lx: %s\n", msr, strerror(errno));
        close(fd);
        return 1;
    }

    printf("cpu%d: msr[0x%lx] = 0x%016llx\n",
           cpu, msr, (unsigned long long)val);

    close(fd);
    return 0;
}
