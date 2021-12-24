# PDFSelectionSample
This is the project for Apple engineers  debugging PDFKit selection


# Steps to reproduce

0. Double click any word, a selection would be made around the word

1. Click the textbox at the top of the interface

2. Double click any word again, no selection could be found, but in the console, selection still made and printed.


# Code Explanation

1. PDFKit view is a wrapper of PDFView

2. IvyPDF View is PDFView Extension, which adds LongPress Selection and Double Tap Selection. 

3. Double Tap is to select an word automatically on which user double taps. 

4. panSelection is to select words on which  fingers press. It's similar to PDFKit default long press, though it ends at the exact point where users lift their fingers.

5. Two closures provided to log pdfview and selection  in the console so when selection is not visible but could still be found what is happening.

