#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <sys/types.h>

#ifndef IP_PATH
#define IP_PATH "/usr/bin/ip"
#endif

#ifndef SETPRIV_PATH
#define SETPRIV_PATH "/usr/bin/setpriv"
#endif

#define len(x) (sizeof (x) / sizeof ((x)[0]))

_Static_assert(sizeof(uid_t) * CHAR_BIT == 32, "This program assumes uid_t is 32 bits");

int main(int argc, char **argv) {
    if (argc < 2) {
        fputs("mv-incl: no program specified\n", stderr);
        return 1;
    }

    char uid[11], gid[11];
    snprintf(uid, sizeof uid, "%u", getuid());
    snprintf(gid, sizeof gid, "%u", getgid());

    char *cmd[] = {
        IP_PATH, "netns", "exec", "mv-incl",
        SETPRIV_PATH, "--reuid", uid, "--regid", gid, "--keep-groups",
        "--",
    };
    char *args[len(cmd) + argc];
    memcpy(args, cmd, sizeof cmd);
    memcpy(args + len(cmd), argv + 1, argc * sizeof *argv);

    execv(args[0], args);
    perror("execv");
    return 1;
}
