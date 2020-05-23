import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.file.*;
import java.util.HashSet;
import java.util.function.*;

public class CopyFileRecursively implements Runnable {
	private Path fileFrom;
	private Path fileTo;
	private boolean simulationMode;
	private Consumer<String> logger;
	private Runnable callbackComplete;
	private boolean stopFlag = false;
	private HashSet<String> shortcutHashSet;

	public CopyFileRecursively(Path fileFrom, Path fileTo){
		this(fileFrom, fileTo, false);
	}

	public CopyFileRecursively(Path fileFrom, Path fileTo, boolean simulationMode){
		this(fileFrom, fileTo, simulationMode, System.out::print);
	}

	public CopyFileRecursively(Path fileFrom, Path fileTo, boolean simulationMode, Consumer<String> logger){
		this(fileFrom, fileTo, simulationMode, logger, null);
	}
	
	public CopyFileRecursively(Path fileFrom, Path fileTo, boolean simulationMode, Consumer<String> logger,
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
			log("========== 成功：処理が成功しました                         ==========\n");

		} catch ( Exception e ) {
			StringWriter sw = new StringWriter();
			PrintWriter pw = new PrintWriter(sw);
			e.printStackTrace(pw);
			pw.flush();
			log( sw.toString() );
			log("========== 失敗：処理の途中で例外が発生しました          ==========\n");

		} finally {
			if (callbackComplete != null){
				callbackComplete.run();
			}
		}
	}
	
	private void copyFile(Path fileFrom, Path fileTo) throws Exception{
		if ( stopFlag ) {
			throw new Exception("中断されました");
		}
		log(" >> コピー元： " + fileFrom + "\n");
		
		if ( Files.isDirectory(fileFrom, LinkOption.NOFOLLOW_LINKS) ){
			fileTo = Paths.get( fileTo.toString(), fileFrom.getFileName().toString());
			log("  * [フォルダ] コピー先は " + fileTo.toString() + "\n");
			if ( Files.exists(fileTo) && ! Files.isDirectory(fileTo)) {
				log("  !!コピー先にフォルダ以外のファイルがあります。削除して再実行してください\n");
				throw new Exception(" !!コピー先にフォルダ以外のファイルがあります。削除して再実行してください\n");
			}else if ( ! Files.exists(fileTo) && ! simulationMode) {
				Files.createDirectory(fileTo);
			}
			
			DirectoryStream<Path> dirList = Files.newDirectoryStream(fileFrom);
			for ( Path p : dirList ){
				copyFile(p, fileTo);
			}
		} else if ( WindowsShortcut.isPotentialValidLink(fileFrom.toFile())){
			WindowsShortcut shortcut = new WindowsShortcut(fileFrom.toFile());
			fileFrom = Paths.get(shortcut.getRealFilename());
			log("  * [ショートカット] 実際は: " + fileFrom.toString() + "\n");
			
			if ( ! shortcutHashSet.contains(fileFrom.toString())) {
				shortcutHashSet.add(fileFrom.toString());
				log("  * ショートカットのリンク先を展開します ");

				if ( Files.exists(fileFrom)) {
					copyFile(fileFrom,fileTo);
				} else {
					log("  !! リンク先のファイルが存在しないのでスキップします\n");
				}
			} else {
				//TODO:２回目のショートカットは何もコピーしない、だけではなく何かいい方法はないか
				log("  !! 同じショートカットが再度現れたのでスキップします\n");
			}
			
		} else if ( Files.isReadable(fileFrom) ) {
			fileTo = Paths.get( fileTo.toString(), fileFrom.getFileName().toString());
			log("  * [通常ファイル]  コピー先は " + fileTo.toString() + "\n");
			if ( Files.exists(fileTo) &&
					Files.getLastModifiedTime(fileFrom).equals(Files.getLastModifiedTime(fileTo))){
				log("  * ファイルの更新時刻がコピー元とコピー先で同じなので、コピーはスキップします。\n");
			}

			if ( ! simulationMode ) {
				Files.copy(fileFrom, fileTo, StandardCopyOption.COPY_ATTRIBUTES, StandardCopyOption.REPLACE_EXISTING);
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
	
	public static void main(String args[]){
		Path fileFrom = Paths.get("C:\\TEMP\\from");
		Path fileTo   = Paths.get("C:\\TEMP\\copyto");
		boolean simulationMode = false;
		
		if ( args.length >=2 ) {
			fileFrom = Paths.get(args[0]);
			fileTo = Paths.get(args[1]);
		}
		
		if ( ! Files.exists(fileFrom) ) {
			System.out.println("コピー元が存在しません: " + fileFrom.toString());
			System.exit(1);
		}

		if ( ! Files.exists(fileTo) || !Files.isDirectory(fileTo) ) {
			System.out.println("コピー先がフォルダではありません: " + fileTo.toString());
			System.exit(1);			
		}
		
		if ( args.length >= 3 ) {
			simulationMode = Boolean.parseBoolean(args[2]);
		}
		
		System.out.println("========== 以下のパラメータで実行します ==========");
		System.out.println("    コピー元： " + fileFrom.toString());
		System.out.println("    コピー先： " + fileTo.toString());
		System.out.println("    シミュレーション： " + simulationMode);

		System.out.println("========== コピー開始                         ==========");

		CopyFileRecursively cfr = new CopyFileRecursively(fileFrom, fileTo, simulationMode);
		cfr.run();
	}
	
}