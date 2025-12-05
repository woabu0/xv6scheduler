#include "kernel/types.h"
#include "user/user.h"

void run_child(int id)
{
    printf("Child %d running\n", id);

    // Busy loop to simulate work
    for (int i = 0; i < 200000000; i++)
        ;

    printf("Child %d finished\n", id);
    exit(0);
}

int main()
{
    int pid1 = fork();
    if (pid1 == 0)
        run_child(1);

    int pid2 = fork();
    if (pid2 == 0)
        run_child(2);

    int pid3 = fork();
    if (pid3 == 0)
        run_child(3);

    // Parent waits for children in FIFO order
    int status;
    wait(&status);
    wait(&status);
    wait(&status);

    exit(0);
}
