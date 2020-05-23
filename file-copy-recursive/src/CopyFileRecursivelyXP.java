import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.channels.FileChannel;
import java.util.HashSet;
import java.util.function.*;

public class CopyFileRecursivelyXP implements Runnable {
	private File fileFrom;
	private File fileTo;
	private boolean simulationMode;
	private Consumer<String> logger;
	private Runnable callbackComplete;
	private boolean stopFlag = false;
	private HashSet<String> shortcutHashSet;

	public CopyFileRecursivelyXP(File fileFrom, File fileTo){
		this(fileFrom, fileTo, false);
	}

	public CopyFileRecursivelyXP(File fileFrom, File fileTo, boolean simulationMode){
		this(fileFrom, fileTo, simulationMode, System.out::print);
	}

	public CopyFileRecursivelyXP(File fileFrom, File fileTo, boolean simulationMode, Consumer<String> logger){
		this(fileFrom, fileTo, simulationMode, logger, null);
	}
	
	public CopyFileRecursivelyXP(File fileFrom, File fileTo, boolean simulationMode, Consumer<String> logger,
			Runnable callbackComplete ){
		this.fileFrom = fileFrom;
		this.fileTo = fileTo;
		this.simulationMode = simulationMode;
		this.logger = logger;
		this.callbackComplete = callbackComplete;
		shortcutHashSet = new HashSet<String>();
	}
	
	public void run (){
		try {
			copyFile(fileFrom, fileTo);
		} catch ( Exception e ) {
			StringWriter sw = new StringWriter();
			PrintWriter pw = new PrintWriter(sw);
			e.printStackTrace(pw);
			pw.flush();
			log( sw.toString() );
		} finally {
			if (callbackComplete != null){
				callbackComplete.run();
			}
		}
	}
	
	private void copyFile(File fileFrom, File fileTo) throws Exception{
		if ( stopFlag ) {
			throw new Exception("中断されました");
		}
		
		log(" >> コピー元： " + fileFrom + "\n");
		
		
		if ( fileFrom.isDirectory()){
			fileTo = new File( fileTo.toString(), fileFrom.getName());
			log("  * [フォルダ] コピー先は " + fileTo.toString() + "\n");
			if ( fileTo.exists() && ! fileTo.isDirectory()) {
				log("  !!コピー先にフォルダ以外のファイルがあります。削除して再実行してください\n");
				throw new Exception(" !!コピー先にフォルダ以外のファイルがあります。削除して再実行してください\n");
			}else if ( ! fileTo.exists() && ! simulationMode) {
				fileTo.mkdir();
			}
			File[] list = fileFrom.listFiles();
			for ( File p : list ){
				copyFile(p, fileTo);
			}
		} else if ( WindowsShortcut.isPotentialValidLink(fileFrom)){
			log("  * [ショートカット] 実際は: ");
			WindowsShortcut shortcut = new WindowsShortcut(fileFrom);
			fileFrom = new File(shortcut.getRealFilename());
			log( fileFrom.toString() + "\n");
			
			if ( ! shortcutHashSet.contains(fileFrom.toString())) {
				shortcutHashSet.add(fileFrom.toString());
				if ( fileFrom.exists()) {
					copyFile(fileFrom,fileTo);
				} else {
					log("  !! リンク先のファイルが存在しないのでスキップします\n");
				}
			} else {
				//TODO:２回目のショートカットは何もコピーしない、だけではなく何かいい方法はないか
				log("  !! 同じショートカットが再度現れたのでスキップします\n");
			}
			
		} else if ( fileFrom.exists() ) {
			fileTo = new File( fileTo.toString(), fileFrom.getName());
			log("  * [通常ファイル]  コピー先は " + fileTo.toString() + "\n");
			if ( fileTo.exists() &&
					fileFrom.lastModified() == fileTo.lastModified()){
				log("  * ファイルの更新時刻がコピー元とコピー先で同じなので、コピーはスキップします。\n");
			}
			if ( ! simulationMode ) {
				fileCopy(fileFrom, fileTo,true);
			}
		} else {
			throw new Exception("予期しないファイル種類です");
		}
	}
	
	public void stop(){
		this.stopFlag = true;
	}
	
	private void log(String s){
		logger.accept(s);
	}
	

	
	
	private static void fileCopy(File srcFile, File destFile, boolean preserveFileDate) throws IOException {
	    if (destFile.exists() && destFile.isDirectory()) {
	        throw new IOException("Destination '" + destFile + "' exists but is a directory");
	    }
	    
	    FileChannel input = new FileInputStream(srcFile).getChannel();
	    try {
	    	FileChannel output = new FileOutputStream(destFile).getChannel();
	        try {
	            output.transferFrom(input, 0, input.size());
	        } finally {
	        	if (output != null) try { output.close(); } catch (IOException e) {}
	        }
	     } finally {
	    	 if (input != null) try { input.close(); } catch (IOException e) {}
	     }

	    if (srcFile.length() != destFile.length()) {
	        throw new IOException("Failed to copy full contents from '" +
	            srcFile + "' to '" + destFile + "'");
	    }
	    if (preserveFileDate) {
	        destFile.setLastModified(srcFile.lastModified());
	    }
	}
	public static void main(String args[]){
		File fileFrom = new File("C:\\TEMP\\from");
		File fileTo   = new File("C:\\TEMP\\copyto");
		boolean simulationMode = false;
		
		if ( args.length >=2 ) {
			fileFrom = new File(args[0]);
			fileTo = new File(args[1]);
		}
		
		if ( ! fileFrom.exists() || ! fileFrom.isDirectory() ) {
			System.out.println("コピー元がフォルダではありません: " + fileFrom.toString());
			System.exit(1);
		}
		
		if ( ! fileTo.exists() || ! fileTo.isDirectory() ) {
			System.out.println("コピー先がフォルダではありません: " + fileTo.toString());
			System.exit(1);			
		}
		
		if ( args.length >= 3 ) {
			simulationMode = Boolean.parseBoolean(args[2]);
		}
		
		System.out.println("以下のパラメータで実行します");
		System.out.println("    コピー元： " + fileFrom.toString());
		System.out.println("    コピー先： " + fileTo.toString());
		System.out.println("    シミュレーション： " + simulationMode);
		
		CopyFileRecursivelyXP cfr = new CopyFileRecursivelyXP(fileFrom, fileTo, simulationMode);
		cfr.run();
	}
	
}