import random
def main():
    f=open("KMP_Input_3000000.txt","w+")
    n= 3000000
    for i in range(n/2):
        f.write("%c" %random.choice('ACGT') )
    f.write('ACGTC' );
    for i in range(n/2 -10):
        f.write("%c" %random.choice('ACGT') )
    f.write('ACGTC' );    
    f.close()
    
if __name__=="__main__":
    main()