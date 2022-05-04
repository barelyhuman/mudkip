import "std/sequtils"

proc createChunks*[T](data: seq[T], limit: int): seq[seq[T]] =
    ## Takes in a sequence data and limit and returns
    ## a sequence of sequence to process as batches
    return data.distribute(limit)
