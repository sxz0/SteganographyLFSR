# SteganographyLFSR
Sage implementation of an Steganography application in SAGE to hidde messages in a BMP image. It combines the steganography with cryptography to ensure the confidentiality and integrity of the message.

The application first set to 0 the value of the first bit of every byte of the BMP image. Then, it uses a LFSR cypher to secure the text message and then put the message in the lasts bits of the bytes of the image.
For the LFSR algorithm, the input are two arrays:
  An array with the polynomial exponents
  An array with the binary input to the poly

To ensure the correct text hiddement, the image must have a size larger than the text to hidde, and the LFSR input should produce a key also larger than the number of bits of the text that you want to hidde.

The method to hidde the information is: hideText, which receives as parameters the route of the BMP image used as base, the text to hidde, the LFSR exponents in an array and the LFSR input in an array. The resultant image is written in a file with the same name that the input and ".out.bmp" at the end.
The method to revocer the text is: recoverText, which recevices as parameters the route of the BMP image with the hidden text, and the LFSR params used to cypher the original text.
