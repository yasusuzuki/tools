import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollBar;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.SwingWorker;
import javax.swing.text.DefaultCaret;

import java.nio.file.*;

import java.awt.BorderLayout;
import java.awt.Container;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.AdjustmentEvent;
import java.awt.event.AdjustmentListener;
import java.io.File;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Iterator;
import java.util.List;
import java.util.function.Consumer;

public class UISwing {

	private JTextArea logArea;
	private JTextField copyFromFileLabel;
	private JTextField copyToFileLabel;
	private boolean simulationMode;
	private JFrame frame;

	public void init() {
		frame = new JFrame("ファイルコピーツール");
		frame.setSize(600,400);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);


	    // copy from
	    JPanel panelFileFrom = new JPanel();
	    JButton buttonFileFrom = new JButton("フォルダを選択");
	    JLabel copyFromLabel = new JLabel("コピー元");
	    copyFromFileLabel = new JTextField(20);
	    copyFromFileLabel.setText( "C:\\tmp\\from" );

	    panelFileFrom.add(buttonFileFrom);
	    panelFileFrom.add(copyFromLabel);
	    panelFileFrom.add(copyFromFileLabel);

	    // copy to
	    JPanel panelFileTo = new JPanel();
	    JButton buttonFileTo = new JButton("フォルダを選択");
	    JLabel copyToLabel = new JLabel("コピー先");
	    copyToFileLabel = new JTextField(20);
	    copyToFileLabel.setText( "C:\\tmp\\to" );
	    panelFileTo.add(buttonFileTo);
	    panelFileTo.add(copyToLabel);
	    panelFileTo.add(copyToFileLabel);
	    
	    JPanel northPanel = new JPanel();

		northPanel.setLayout(new BoxLayout(northPanel, BoxLayout.Y_AXIS));
		northPanel.add(panelFileFrom);
		northPanel.add(panelFileTo);
	    
	    // log area
	     logArea = new JTextArea(20,60);
	    logArea.append("ここにログメッセージが表示されます\n");
	    DefaultCaret caret = (DefaultCaret)logArea.getCaret();
	    caret.setUpdatePolicy(DefaultCaret.ALWAYS_UPDATE);
	    JScrollPane scrollpane = new JScrollPane(logArea);


	    
	    // action area
	    JButton runButton = new JButton("実行");
	    JButton abortButton = new JButton("中止");
	    JPanel southPanel = new JPanel();
	    JCheckBox simulationModeButton = new JCheckBox("シミュレーションモード");
	    simulationModeButton.setSelected(simulationMode);
	    southPanel.add(runButton);
	    southPanel.add(abortButton);
	    southPanel.add(simulationModeButton);
	    
	    
	    
	    Container contentPane = frame.getContentPane();
		
	    contentPane.add(northPanel, BorderLayout.NORTH);
	    contentPane.add(scrollpane,BorderLayout.CENTER);
	    contentPane.add(southPanel,BorderLayout.SOUTH);

		addShortcutCopyJob(runButton, abortButton, simulationModeButton);
		addOpenDialogForFile(buttonFileFrom, copyFromFileLabel);
		addOpenDialogForFile(buttonFileTo, copyToFileLabel);

	    frame.pack();
		frame.setVisible(true);

	}

	private void addOpenDialogForFile(JButton button, JTextField directoryPathText){
		button.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent event) {
				JFileChooser openDialog = new JFileChooser(directoryPathText.getText());
				openDialog.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);

				int selected  = openDialog.showOpenDialog(frame);
				if ( selected == JFileChooser.APPROVE_OPTION ) { 
					directoryPathText.setText( openDialog.getSelectedFile().getPath() );
					logText("フォルダ選択：　"+ openDialog.getSelectedFile().getPath());
				}
			}
		});
	}
	
	CopyFileRecursively cfr = null;
	private void addShortcutCopyJob(JButton button, JButton abortButton, JCheckBox simulationModeButton ){
		
		abortButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent event) {
				logText("実行中止ボタンが押されました..\n");
				button.setEnabled(true);
				abortButton.setEnabled(false);
				if ( cfr != null ){
					cfr.stop();
				}
			}
		});
		
		button.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent event) {
				logText("作業スレッド：" + Thread.currentThread().getName()+" でUIイベントを受け付けました\n");

				logText("=======================================================\n");

				logText(" コピーを実行します..\n");
				logText("コピー元: " + copyFromFileLabel.getText() + " コピー先: " + copyToFileLabel.getText() + "\n");
				Path fileFrom = Paths.get(copyFromFileLabel.getText());
				Path fileTo = Paths.get(copyToFileLabel.getText());

				boolean simulationModeFlag = simulationModeButton.isSelected();

				if (simulationModeFlag) {
					logText("シミュレーションモード＝TRUE　ファイルコピーはしません\n");
				} else {
					logText("シミュレーションモード＝FALSE　実際にファイルコピーをします\n");
				}

				if (fileFrom == null ||  ! Files.exists(fileFrom)) {
					logText("選択したコピー元が存在しません。\n");
					return;
				}
				// コピー先のルートフォルダがなければ実行はしない。ただし、シミュレーションモードではチェックしない。
				if (!simulationModeFlag && (fileTo == null || !Files.isDirectory(fileTo))) {
					logText("選択したコピー先はフォルダではありません。フォルダを選択してください\n	");
					return;
				}

				button.setEnabled(false);
				abortButton.setEnabled(true);
				SwingWorker<Object, String> swingWorker = new SwingWorker<Object, String>() {
					Consumer<String> lmd = (logMessage) -> {
						publish(logMessage);
					};

					protected Object doInBackground() throws Exception {
						logText("作業スレッド：" + Thread.currentThread().getName() + " で開始します\n");

						cfr = new CopyFileRecursively(fileFrom, fileTo, simulationModeButton.isSelected(), lmd, null);
						cfr.run();

						return null;
					}

					@Override
					protected void process(List<String> chunks) {
						for (String s : chunks) {
							logText(s);
						}
					}

					@Override
					protected void done() {
						button.setEnabled(true);
						abortButton.setEnabled(false);
						logText(" * 処理が終了しました\n\n");
						
					}
					

				};
				swingWorker.execute();

				logText("\n");
				
			}

		});
	}	
	
	
	DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
	
	private void logText(String s){
		System.out.print(LocalDateTime.now().format(dtf) + " " + s);
		logArea.append(LocalDateTime.now().format(dtf) + " " + s);
		//Keep scrollbar to bottom https://tips4java.wordpress.com/2008/10/22/text-area-scrolling/
		logArea.setCaretPosition(logArea.getDocument().getLength());

	}
		
	public void setFromFilePath(String path) {
		copyFromFileLabel.setText(path);
	}
	
	public void setToFilePath(String path) {
		copyToFileLabel.setText(path);
	}
	
	public void setSimulationMode(boolean flag) {
		this.simulationMode = true;
	}
	
	
    public static void main (String args[]) {
		//Starting up UI. blocking the thread. 
		UISwing ui = new UISwing();
		ui.init();

		if (args.length >= 1) {
			ui.setFromFilePath(args[0]);
		}
		
		if (args.length >= 2) {
			ui.setToFilePath(args[1]);
		}
		
		if (args.length >= 3) {
			ui.setSimulationMode(Boolean.valueOf(args[2]));
		}

		
	}
}
