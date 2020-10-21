
import sys

__switch_payload__ = False

if __name__ == '__main__':

    with open(sys.argv[1], 'rb') as in_file:
      pr_file = bytearray(in_file.read())

    #requestString = "POST /configure HTTP/1.1\r\nUser-Agent: curl/7.29.0\r\nHost: localhost:8080\r\nAccept: */*\r\nContent-Length: "+str(data_len)+"\r\nContent-Type: application/x-www-form-urlencoded\r\n\r\n"
    requestString = "POST /configure HTTP/1.1\r\nUser-Agent: curl/7.29.0\r\nContent-Type: application/x-www-form-urlencodedAB\r\n\r\n"

    pr_len = len(pr_file)
    pr_words = int(pr_len/4)
    assert(pr_len %4 == 0)
    print("loaded pr bin file of size {} bytes ({} words)...".format(hex(pr_len), hex(pr_words)))
    byteData = bytearray(requestString.encode())
    if __switch_payload__:
        pr_file_size = len(pr_file)
        assert((pr_file_size % 4) == 0)
        number_of_words = int(pr_file_size/4)
        for i in range(0, number_of_words):
            byteData.append(pr_file[i*4+3])
            byteData.append(pr_file[i*4+2])
            byteData.append(pr_file[i*4+1])
            byteData.append(pr_file[i*4+0])
    else:
        byteData.extend(pr_file)

    byteData.extend(bytearray("\r\n\r\n".encode()))

    #out_string = byteData.decode('iso-8859-1')
    #out_string = ''.join(format(x, '02x') for x in byteData)
    #print(out_string, end='', flush=True)
    
    # TODO: does this destroy encoding?
    #sys.stdout.buffer.write(byteData)
    #with io.open(sys.argv[2], 'wb', newline='\r\n') as outfile:
    with open(sys.argv[2], 'wb') as outfile:
        outfile.write(byteData)
   
    print("POST request exported to: {}".format(sys.argv[2]))

