import argparse
import os, sys
import time
import typing

import torch
import torch.distributed as dist
from torch.nn.parallel import DistributedDataParallel as DDP
from torchvision.models import resnet50
from torchvision.datasets import CIFAR10
import torchvision.transforms as transforms
from torch.utils.data import DistributedSampler, DataLoader
from filelock import FileLock

def parse_command_line():
    parser = argparse.ArgumentParser()    
    parser.add_argument("--device", required=False, type=str, choices=['cpu', 'cuda'], default="cuda")
    parser.add_argument("--num_epochs", required=False, type=int, default=2)
    parser.add_argument("--batch_size", required=False, type=int, default=128)
    parser.add_argument("--num_workers", required=False, type=int, default=1)
    parser.add_argument("--distributed", required=False, action="store_true", default=False)
    args = parser.parse_args()
    
    # default args for distributed
    args.world_size = 1
    args.world_rank = 0
    args.local_rank = 0
   
    return args

def load_dataset(args):
    # standardization values for CIFAR10 dataset
    mean = (0.4919, 0.4827, 0.4472)
    std = (0.2022, 0.1994, 0.2010)
    
    # define the following transformations
    # - resize to 224x224
    # - transform back to tensor
    # - normalize data using mean and std from above
    trans = None # TODO
    
    # load CIFAR10 dataset splits for train and test and apply the transformations
    # note: you need to download the dataset once at the beginning
    ds_train = None # TODO
    ds_test  = None # TODO
    
    # define distributed samplers (only for distributed version)
    sampler_train, sampler_test = None, None
    if args.distributed:
        pass # TODO
    
    # finally create separate data loaders for train and test with the following common arguments
    common_kwargs = {"batch_size": args.batch_size, "num_workers": args.num_workers, "pin_memory": True}
    loader_train = None # TODO
    loader_test  = None # TODO
    
    return loader_train, loader_test

def train(args, model, loader_train, optimizer, epoch):
    # use a CrossEntropyLoss loss function
    loss_func = None # TODO

    # set model into train mode
    model.train()
    
    # track accuracy for complete epoch
    total, correct = 0, 0
    total_steps = len(loader_train)
    
    elapsed_time = time.time()
    for i, (x_batch, y_batch) in enumerate(loader_train):
        # transfer data to the device
        # TODO

        # run forward pass
        # TODO
        
        # calculate loss
        loss = None # TODO
        
        # run backward pass and optimizer to update weights
        # TODO
        
        # track training accuracy
        # TODO
        total += y_batch.size(0)
        correct += None # TODO
        
        if args.world_rank == 0 and i % 20 == 0:
            print(f"Epoch {epoch+1}/{args.num_epochs}\tStep {i:4d} / {total_steps:4d}")
            sys.stdout.flush()
    elapsed_time = time.time() - elapsed_time

    if args.world_rank == 0:
        print(f"Epoch {epoch+1}/{args.num_epochs}\tElapsed: {elapsed_time:.3f} sec\tAcc: {(correct/total):.3f}")
        sys.stdout.flush()

def test(args, model, loader_test, epoch):
    # set model into evaluation mode
    model.eval()
    
    with torch.no_grad():
        correct, total = 0, 0
        for i, (x_batch, y_batch) in enumerate(loader_test):
            # transfer data to the device
            # TODO
            
            # predict classes
            # TODO
            
            # track test accuracy
            total += y_batch.size(0)
            correct += None # TODO
        
        if args.world_rank == 0:
            print(f"Epoch {epoch+1}/{args.num_epochs}\tTest Acc: {(correct/total):.3f}")
            sys.stdout.flush()

def setup(args) -> None:

    if args.distributed:
        args.world_size = int(os.environ['WORLD_SIZE'])
        args.world_rank = int(os.environ['RANK'])
        args.local_rank = int(os.environ['LOCAL_RANK'])
        # initialize process group and wait for completion (only for distributed version)
        # TODO

    # set gpu device on local machine
    if args.device == 'cuda':
        if args.distributed:
            # assign GPUs to processes on the local system (only for distributed version)
            torch.cuda.set_device(args.local_rank)
            args.device = torch.device(f'cuda:{args.local_rank}')
        # optimization hint for torch runtime
        torch.backends.cudnn.benchmark = True

    print("Current configuration:")
    for arg in vars(args):
        print(f"  --{arg}, {getattr(args, arg)}")

def cleanup(args: typing.Dict[str, typing.Any]):
    if args.distributed:
        # wait for processes and destory group again (only for distributed version)
        # TODO
        pass

def main():
    # parse command line arguments
    args = parse_command_line()

    # run setup (e.g., create distributed environment if desired)
    setup(args)
    
    # get data loaders for train and test split
    loader_train, loader_test = load_dataset(args)
    
    # create resnet50 with random weights
    model = resnet50().to(args.device)
    if args.distributed:
        # use DDP to wrap model (only for distributed version)
        # TODO
        pass

    # initialize optimizer with model parameters
    optimizer = None # TODO

    # train and test model for configured number of epochs
    for epoch in range(args.num_epochs):
        train(args, model, loader_train, optimizer, epoch)
        test (args, model, loader_test, epoch)

    # cleaup env
    cleanup(args)

if __name__ == "__main__":
    main()