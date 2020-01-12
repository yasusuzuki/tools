import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfReader;
import com.itextpdf.kernel.pdf.PdfWriter;

/**
 * このサンプルがベース
 * https://github.com/itext/i7js-examples/blob/develop/src/test/java/com/itextpdf/samples/sandbox/fonts/MergeAndAddFont.java
 * @author yasu
 *
 */
public class iTextApp {
	public static void concatenatePdfs(List<File> infiles, File outfile, boolean smart_mode) throws FileNotFoundException, IOException {
			PdfWriter writer = new PdfWriter(outfile);
			writer.setSmartMode(smart_mode);
		    PdfDocument document = new PdfDocument(writer);
		    document.initializeOutlines();
   
		    for (File inFile : infiles) {
		        PdfReader reader = new PdfReader(inFile);
		        PdfDocument pdfInnerDoc = new PdfDocument(reader);
			    pdfInnerDoc.copyPagesTo(1, pdfInnerDoc.getNumberOfPages(), document);
			    pdfInnerDoc.close();

		    }
		    document.close();
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
			iTextApp.concatenatePdfs(Arrays.asList(infiles),destfile,smart_mode);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		System.out.println("DONE!");

	}
}
