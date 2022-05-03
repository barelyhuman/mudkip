
proc createChunks*[T](data: seq[T], limit: int): seq[seq[T]] =
    ## Takes in a sequence data and limit and returns
    ## a sequence of sequence to process as batches

    let totalLength = len(data);
    var chunkSet: seq[seq[T]] = @[]
    var offset = 0
    for i in 0..totalLength:
        var chunk: seq[T];
        var nextOffset = offset * limit + limit;

        if nextOffset > totalLength:
            break

        for j in offset..nextOffset:

            if len(chunk) >= limit:
                break

            chunk.add(data[j])
            offset = nextOffset;

        chunkSet.add(chunk)

    return chunkSet
