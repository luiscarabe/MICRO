##### Fourth deliverable
Luis Cárabe and Juan Riera

To generate all the executables type make.
Type make clean to clean the directory (delete the .map, .obj, .com and .exe files)

Important: 

We only encrypt and decrypt lowecase letters, other chars will remain unmodifiable.

It is also important not to type any '$' into the decryption because it will cause malfunction.

To check if our driver is installed, we only look if first 4 bytes of the service routine belong to the program that is to be uninstalled or installed, so, it WILL NOT distinguish between p4a.com and p4a2.com, so:

When executing  p3c.exe the driver p4a2.com must have been the last one to be installed, if not the encrypted/decrypted strings will be printed twice.
