import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.*;
import org.eclipse.swt.layout.*;
import org.eclipse.swt.events.*;

import java.io.File;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.function.Consumer;

public class UI {
	private Display display;
	private Shell shell;
	private Text logText;
	private String fileFromPath = "C:\\tmp\\from";
	private String fileToPath = "C:\\tmp\\to";

	public UI() {
		GridData gridData;

		display = new Display();
		shell = new Shell(display);
		shell.setText("ファイルコピーツール");

		// 6列のグリッドレイアウト。各列のグリッド幅は固定(true)
		Layout layout = new GridLayout(6, true);
		shell.setLayout(layout);

		// コピー元フォルダ選択ボタン
		Button buttonFileFrom = new Button(shell, SWT.PUSH);
		buttonFileFrom.setText("フォルダを選択");
		gridData = new GridData(SWT.FILL, SWT.FILL, false, false, 1, 1);
		buttonFileFrom.setLayoutData(gridData);

		Label copyFromLabel = new Label(shell, SWT.NONE);
		copyFromLabel.setText("コピー元: ");
		copyFromLabel.setLayoutData(new GridData(SWT.FILL, SWT.FILL, false, false, 1, 1));
		

		Text copyFromFileLabel = new Text(shell, SWT.BORDER);
		copyFromFileLabel.setText(fileFromPath);
		copyFromFileLabel.setLayoutData(new GridData(SWT.FILL, SWT.FILL, false, false, 4, 1));

		
		// コピー先フォルダ選択ボタン
		Button buttonFileTo = new Button(shell, SWT.PUSH);
		buttonFileTo.setText("フォルダを選択");
		gridData = new GridData(SWT.FILL, SWT.FILL, false, false, 1, 1);
		buttonFileTo.setLayoutData(gridData);

		Label copyToLabel = new Label(shell, SWT.NONE);
		copyToLabel.setText("コピー先: ");
		copyToLabel.setLayoutData(new GridData(SWT.FILL, SWT.FILL, false, false, 1, 1));

		Text copyToFileLabel = new Text(shell, SWT.BORDER);
		copyToFileLabel.setText(fileToPath);
		copyToFileLabel.setLayoutData(new GridData(SWT.FILL, SWT.FILL, false, false, 4, 1));

		// ログメッセージ表示テキストエリア
		logText = new Text(shell, SWT.BORDER | SWT.WRAP | SWT.MULTI | SWT.V_SCROLL);
		gridData = new GridData(SWT.FILL, SWT.FILL, true, true, 6, 1);
		logText.setLayoutData(gridData);
		logText.setText("ここにログメッセージが表示されます\n");

		logText.addKeyListener(new KeyAdapter() {
		    @Override
		    public void keyPressed(KeyEvent e)
		    {
		        if (e.stateMask == SWT.CTRL && e.keyCode == 'a') {
		            logText.selectAll();
		            e.doit = false;
		        }
		    }
		});
		// コピー実行ボタン
		Button runButton = new Button(shell, SWT.PUSH);
		runButton.setText("実行");
		gridData = new GridData(SWT.FILL, SWT.FILL, false, false, 1, 1);
		runButton.setLayoutData(gridData);

		// 中止ボタン
		Button abortButton = new Button(shell, SWT.PUSH);
		abortButton.setText("中止");
		abortButton.setEnabled(false);
		gridData = new GridData(SWT.FILL, SWT.FILL, false, false, 1, 1);
		abortButton.setLayoutData(gridData);

		// シミュレーションモードのチェックボックス
		Button simulationModeButton = new Button(shell, SWT.CHECK);
		simulationModeButton.setText("シミュレーションモード");

		// イベントの登録
		addShortcutCopyJob(runButton, abortButton, simulationModeButton);
		// addOpenDialogForFileFrom(buttonFileFrom,
		// copyFromFileLabel,"C:\\TEMP\\from")
		addOpenDialogForFileFrom(buttonFileFrom, copyFromFileLabel);
		addOpenDialogForFileTo(buttonFileTo, copyToFileLabel);
	}
	
	private void addOpenDialogForFileFrom(Button button, Text label){
		button.addSelectionListener(new SelectionListener() {
			public void widgetSelected(SelectionEvent event) {
				DirectoryDialog openDialog = new DirectoryDialog(shell, SWT.OPEN);
				if ( new File(label.getText()).isDirectory()) {
					openDialog.setFilterPath(label.getText());
				}
				String openFileName = openDialog.open();
				if ( openFileName != null ) { 
					fileFromPath = openFileName;
					label.setText(openFileName);
				}
			}
			public void widgetDefaultSelected(SelectionEvent event) {
				//Do nothing
			}
		});
	}
	
	private void addOpenDialogForFileTo(Button button, Text label){
		button.addSelectionListener(new SelectionListener() {
			public void widgetSelected(SelectionEvent event) {
				DirectoryDialog openDialog = new DirectoryDialog(shell);
				if ( new File(label.getText()).isDirectory()) {
					openDialog.setFilterPath(label.getText());
				}
				String openFileName = openDialog.open();
				if ( openFileName != null ) { 
					fileToPath = openFileName;
					label.setText(openFileName);
				}
			}
			public void widgetDefaultSelected(SelectionEvent event) {
				//Do nothing
			}
		});
	}
	
	private void logText(String s){
		logText.append(LocalDate.now() + " " + s);
		System.out.print(LocalDate.now() + " " + s);
	}
	
	CopyFileRecursivelyXP cfr = null;
	private void addShortcutCopyJob(Button button, Button abortButton, Button simulationModeButton ){
		
		abortButton.addSelectionListener(new SelectionListener() {
			public void widgetSelected(SelectionEvent event) {
				logText("実行中止ボタンが押されました..\n");
				button.setEnabled(true);
				abortButton.setEnabled(false);
				if ( cfr != null ){
					cfr.stop();
				}
			}
			public void widgetDefaultSelected(SelectionEvent event) {
				//Do nothing
			}
		});
		
		
		button.addSelectionListener(new SelectionListener() {
			public void widgetSelected(SelectionEvent event) {
				logText("=======================================================\n");

				logText(" コピーを実行します..\n");
				logText("コピー元: " + fileFromPath + " コピー先: " + fileToPath + "\n");
				File fileFrom = new File(fileFromPath);
				File fileTo = new File(fileToPath);
				
				boolean simulationModeFlag = simulationModeButton.getSelection();

				if ( simulationModeFlag ) {
					logText("シミュレーションモード＝TRUE　ファイルコピーはしません\n");
				} else {
					logText("シミュレーションモード＝FALSE　実際にファイルコピーをします\n");
				}

				if ( fileFrom == null || ! fileFrom.isDirectory() ) { 
					logText("選択したコピー元はフォルダではありません。フォルダを選択してください");
					return;
				}
				//コピー先のルートフォルダがなければ実行はしない。ただし、シミュレーションモードではチェックしない。
				if ( !simulationModeFlag && ( fileTo == null || ! fileTo.isDirectory()) ) { 
					logText("選択したコピー先はフォルダではありません。フォルダを選択してください");
					return;
				}


				try {
					Consumer<String> lmd = (s) -> {
						Display.getDefault().syncExec( () -> {
							logText(s);
						});
					};
					Runnable callbackComplete = () -> {
						Display.getDefault().syncExec( () -> {
							button.setEnabled(true);
							abortButton.setEnabled(false);
							logText("\n * 処理が完了しました\n\n");
						});
					};
					button.setEnabled(false);
					abortButton.setEnabled(true);
					cfr = new CopyFileRecursivelyXP(fileFrom,
							fileTo,
							simulationModeButton.getSelection(),
							lmd,
							callbackComplete); 
					//非同期呼び出し SWTは別スレッドからのアクセスを禁止しているため、以下のメソッドをスレッドを実行する必要がある
					new Thread(cfr).start();
				} catch (Exception e) {
					e.printStackTrace();
					logText( e.toString() );
				}

				logText("\n");
			}
			public void widgetDefaultSelected(SelectionEvent event) {
				//Do nothing
			}
		});
	}
	
	public void start(){
        shell.setSize( 640, 480 );
        shell.open();
 
        while (!shell.isDisposed()) {
            if (!display.readAndDispatch()) {
                display.sleep();
            }
        }
        display.dispose();
	}
	 
    public static void main (String args[]) {
		//Starting up UI. blocking the thread. 
		UI ui = new UI();
		ui.start();
	}
}
