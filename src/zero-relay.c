#include <stdint.h>
#include <stdio.h>
#include <zmq.h>

int main(int argc, char *argv[])
{
  void *context = zmq_init(1);

  // listening to messages
  fprintf(stderr, "Push to *:65454\n");
  void *sub = zmq_socket(context, ZMQ_SUB);
  zmq_bind(sub, "tcp://*:65454");
  zmq_setsockopt(sub, ZMQ_SUBSCRIBE, "", 0);

  // publishing to subscribers
  fprintf(stderr, "Subscribe to *:65455\n");
  void *pub = zmq_socket(context, ZMQ_PUB);
  zmq_bind(pub, "tcp://*:65455");

  // loop
  while (1) {
    int rc;
    int64_t more;
    size_t more_size = sizeof more;
    do {
      zmq_msg_t msg;
      zmq_msg_init(&msg);
      // break if interrupted
      rc = zmq_recvmsg(sub, &msg, 0);
      if (rc == -1) {
        zmq_msg_close(&msg);
        fprintf(stderr, "ERR: %d\n", rc);
        goto done;
      }
      // relay
      zmq_sendmsg(pub, &msg, 0);
      // more parts are to follow?
      rc = zmq_getsockopt(sub, ZMQ_RCVMORE, &more, &more_size);
      zmq_msg_close(&msg);
    } while (more);
  }

done:

  // cleanup
  zmq_close(pub);
  zmq_close(sub);
  zmq_term(context);

  return 0;
}
