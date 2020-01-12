import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.pdf.PdfCopy;
import com.lowagie.text.pdf.PdfImportedPage;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfSmartCopy;

public class openPDFApp {
	/**
	 * Copy from this example
	 * https://www.programcreek.com/java-api-examples/?code=mkl-public/testarea-itext5/testarea-itext5-master/src/test/java/mkl/testarea/itext5/merge/SmartMerging.java
	 * @param documentPaths
	 * @return
	 * @throws IOException
	 * @throws DocumentException
	 */
    public static byte[] Merge(List<File> documentPaths, boolean smart_mode ) throws IOException, DocumentException
    {
        byte[] mergedDocument;

        try (ByteArrayOutputStream memoryStream = new ByteArrayOutputStream())
        {
            Document document = new Document();
            PdfCopy pdfCopy;
            if (smart_mode) {
            	pdfCopy = new PdfSmartCopy(document, memoryStream);
            } else {
            	pdfCopy = new PdfCopy(document, memoryStream);
            }
            document.open();

            for (File docPath : documentPaths)
            {
                PdfReader reader = new PdfReader(docPath.toString());
                try
                {
                    reader.consolidateNamedDestinations();
                    int numberOfPages = reader.getNumberOfPages();
                    for (int page = 0; page < numberOfPages;)
                    {
                        PdfImportedPage pdfImportedPage = pdfCopy.getImportedPage(reader, ++page);
                        pdfCopy.addPage(pdfImportedPage);
                    }
                }
                finally
                {
                    reader.close();
                }
            }

            document.close();
            mergedDocument = memoryStream.toByteArray();
        }

        return mergedDocument;
    }
    
    public static void concatenatePdfs(List<File> infiles, File outfile, boolean smart_mode) throws IOException, DocumentException {
    	byte[] bytes = openPDFApp.Merge(infiles,smart_mode);
    	
    	try (FileOutputStream stream = new FileOutputStream(outfile)) {
    	    stream.write(bytes);
    	}
    }
    
	public static void main(String args[]) {
		if( args.length != 3 ) { 
			System.err.println("Aborted. 3 parameters are reuquired\n"
					+ " 1: SOURCE FOLDER contains pdf to be merged e.g. C:\\tmp\\inputfiles \n"
					+ " 2: DEST FILE e.g. C:\\tmp\\out.pdf \n"
					+ " 3: SMART MODE flag [true or false]\n\n");
			System.exit(1);
		}
		File sourcefolder = new File(args[0]);
		File destfile = new File(args[1]);
		Boolean smart_mode = new Boolean(args[2]);
		
		if ( ! sourcefolder.exists() ) {
			System.out.println("Aborted. source folder not exit");
			System.exit(1);
		}
		if ( ! sourcefolder.isDirectory() ) {
			System.out.println("Aborted. source folder is not directory");
			System.exit(1);
		}
		
		if ( destfile.exists() ) {
			System.out.println("WARN: dest filename already exits. Overwriting..");
			//System.exit(1);
		}
		
		File[] infiles = sourcefolder.listFiles();
		Arrays.sort(infiles);  //標準のファイル名順に並べる
		
		System.out.println("OUTPUT: " + destfile.getAbsolutePath());
		System.out.println("INPUT FOLDER:" + sourcefolder.getAbsolutePath());
		for ( File infile : infiles) {
			System.out.println("INPUT "+infile.getName());
		}
		System.out.println("SMART MODE:" + smart_mode);
		
		System.out.println("Starting PDF merge with SMART MODE");

		try {
			openPDFApp.concatenatePdfs(Arrays.asList(infiles),destfile,smart_mode);
		} catch (DocumentException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		System.out.println("DONE!");

	}
}
