import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Arrays;


import org.apache.pdfbox.io.MemoryUsageSetting;
import org.apache.pdfbox.multipdf.PDFMergerUtility;
import org.apache.pdfbox.pdmodel.PDDocument;

/**
 * こちらを参考
 * https://stackoverflow.com/questions/53420344/how-to-reduce-the-size-of-merged-pdf-a-1b-files-with-pdfbox-or-other-java-library
 * 
 * @author yasu
 *
 */
public class PDFBoxApp {
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

		PDFMergerUtility pdfMerger = new PDFMergerUtility();
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try {
    		pdfMerger.setDestinationStream(baos);

            // iterate list and add files to PDFMergerUtility
            for(File infile : infiles) {            
                pdfMerger.addSource(infile);
            }
            // Merge documents
            pdfMerger.mergeDocuments(MemoryUsageSetting.setupMainMemoryOnly());
        }catch (IOException e) {
            e.printStackTrace();
        }
        
        if ( smart_mode ) {
            //Optimize PDF
    		try {
    			OptimizeAfterMerge app = new OptimizeAfterMerge();
    			PDDocument pdDocument = PDDocument.load(baos.toByteArray());
    			app.optimize(pdDocument);
    			pdDocument.save(destfile);
    		} catch (FileNotFoundException e) {
    			e.printStackTrace();
    		} catch (IOException e) {
    			e.printStackTrace();
    		}
        }

		
		System.out.println("DONE!");
	}
	
}
