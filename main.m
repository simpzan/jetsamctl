#import <Foundation/Foundation.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include "kern_memorystatus.h"

int setHighWaterMark(int pid, int limit) {
    int cmd = MEMORYSTATUS_CMD_SET_JETSAM_HIGH_WATER_MARK;
    int result = memorystatus_control(cmd, pid, limit, 0, 0);
    if (result) {
        fprintf(stderr, "failed to setHighWaterMark of pid %d to %dMB: %d\n", pid, limit, errno);
    }
    return result;
}

int getHightWaterMark(int pid) {
    int size = memorystatus_control(MEMORYSTATUS_CMD_GET_PRIORITY_LIST, 0, 0, NULL, 0);
    if (size < 0) {
        fprintf(stderr, "failed to get priority list size: %d\n", errno);
        return -1;
    }

    memorystatus_priority_entry_t *list = (memorystatus_priority_entry_t *)malloc(size);
    if (!list) {
        fprintf(stderr, "failed to allocate memory of size %d: %d\n", size, errno);
        return -1;
    }

    size = memorystatus_control(MEMORYSTATUS_CMD_GET_PRIORITY_LIST, 0, 0, list, size);
    int count = size / sizeof(memorystatus_priority_entry_t);
    for (int i = 0; i < count; ++i) {
        memorystatus_priority_entry_t *entry = list + i;
        if (entry->pid == pid) return entry->limit;
    }
    return -1;
}

int main(int argc, char **argv, char **envp) {
    char cmd[128] = {0};
    int pid = -1;
    int limit = -1;

    if (argc >= 3) {
        strncpy(cmd, argv[1], sizeof(cmd));
        pid = atoi(argv[2]);
        limit = argc >= 4 ? atoi(argv[3]) : -1;
    } else {
        scanf("%s %d %d", cmd, &pid, &limit);
    }

    if (pid < 1) {
        fprintf(stderr, "invalid pid: %d\n", pid);
        return -1;
    }

    if (!strcmp(cmd, "get")) {
        int limit = getHightWaterMark(pid);
        fprintf(stdout, "get pid:%d limit:%d\n", pid, limit);
    } else if (!strcmp(cmd, "set")) {
        if (limit <= 0) {
            fprintf(stderr, "limit should be valid unsigned int\n");
            return -1;
        }
        int result = setHighWaterMark(pid, limit);
        // fprintf(stdout, "set pid:%d limit:%d result:%d\n", pid, limit, result);
        NSLog(@"set pid:%d limit:%d result:%d\n", pid, limit, result);
    } else {
        fprintf(stderr, "invalid cmd:%s\n", cmd);
    }
	return 0;
}
