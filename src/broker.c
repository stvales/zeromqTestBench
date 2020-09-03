//
//  broker.c
//  zeromqTestBench
//
//  Created by Stephane Vales on 10/08/2020.
//  Copyright © 2020 Ingenuity i/o. All rights reserved.
//

#include <stdio.h>
#include <zyre.h>
#include "config.h"

int main(int argc, const char * argv[]) {
    zyre_t *node = zyre_new ("broker");
    zyre_set_verbose (node);
    zyre_gossip_bind (node, "tcp://%s:%d", IP_ADDRESS, GOSSIP_PORT);
    //endpoint creation and node start are only necessary to receive EXIT notifications
    //and clean our gossip table
    zyre_set_endpoint(node, "tcp://%s:%d", IP_ADDRESS, BROKER_PORT);
    zyre_start(node);
    
    getchar();
//    zloop_t *loop = zloop_new();
//    zloop_start(loop);
//    zloop_destroy(&loop);
    
    zyre_stop(node);
    zyre_destroy(&node);
    return 0;
}

