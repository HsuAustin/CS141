import java.io.*;
import java.util.Hashtable;

public class MainClass {
    public static void main(String[] args) {
        Disk disk = new Disk();
        Printer printer;
        try {printer = new Printer(0);} 
        catch (IOException e) {
            e.printStackTrace();
            return;
        }

        DirectoryManager directory = new DirectoryManager();
        UserThread user0 = new UserThread(0, disk, printer, directory);
        user0.start();
        try {user0.join();} 
        catch (InterruptedException e) {e.printStackTrace();}
        try {printer.close();} 
        catch (IOException e) {e.printStackTrace();}
    }
}

class Disk {
    static final int NUM_SECTORS = 2048;
    static final int DISK_DELAY = 80;
    StringBuffer[] sectors = new StringBuffer[NUM_SECTORS];

    Disk() {for (int i = 0; i < NUM_SECTORS; i++) {sectors[i] = new StringBuffer();}}

    void write(int sector, StringBuffer data) {
        try {Thread.sleep(DISK_DELAY);} 
        catch (InterruptedException e) {}
        sectors[sector].setLength(0);
        sectors[sector].append(data.toString());
    }

    void read(int sector, StringBuffer data) {
        try {Thread.sleep(DISK_DELAY);} 
        catch (InterruptedException e) {}
        data.setLength(0);
        data.append(sectors[sector].toString());
    }
}

class Printer {
    static final int PRINT_DELAY = 275;
    private final FileWriter writer;

    Printer(int id) throws IOException {writer = new FileWriter("PRINTER" + id);}

    void print(StringBuffer data) {
        try {
            Thread.sleep(PRINT_DELAY);
            writer.write(data.toString());
            writer.write("\n");
            writer.flush();
        } catch (Exception e) {e.printStackTrace();}
    }

    void close() throws IOException {writer.close();}
}

class FileInfo {
    int diskNumber;
    int startingSector;
    int fileLength;
}

class DirectoryManager {
    private Hashtable<String, FileInfo> T = new Hashtable<String, FileInfo>();

    void enter(StringBuffer fileName, FileInfo file) {T.put(fileName.toString(), file);}

    FileInfo lookup(StringBuffer fileName) {return T.get(fileName.toString());}
}

class UserThread extends Thread {
    private final int userId;
    private final Disk disk;
    private final Printer printer;
    private final DirectoryManager directory;
    private int nextFreeSector = 0;

    UserThread(int userId, Disk disk, Printer printer, DirectoryManager directory) {
        this.userId = userId;
        this.disk = disk;
        this.printer = printer;
        this.directory = directory;
    }

    public void run() {
        String userFileName = "USER" + userId;
        try {
            FileInputStream inputStream = new FileInputStream(userFileName);
            BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
            String line;
            boolean saving = false;
            StringBuffer currentFileName = null;
            int currentStartSector = 0;
            int currentLength = 0;
            while ((line = reader.readLine()) != null) {
                if (line.startsWith(".save")) {
                    String name = line.substring(5).trim();
                    currentFileName = new StringBuffer(name);
                    saving = true;
                    currentStartSector = nextFreeSector;
                    currentLength = 0;
                } else if (line.startsWith(".end")) {
                    if (saving && currentFileName != null) {
                        FileInfo fi = new FileInfo();
                        fi.diskNumber = 0;
                        fi.startingSector = currentStartSector;
                        fi.fileLength = currentLength;
                        directory.enter(currentFileName, fi);
                    }
                    saving = false;
                    currentFileName = null;
                } else if (line.startsWith(".print")) {
                    String name = line.substring(6).trim();
                    printFile(new StringBuffer(name));
                } else {
                    if (saving && currentFileName != null) {
                        StringBuffer data = new StringBuffer(line);
                        int sector = nextFreeSector;
                        nextFreeSector++;
                        currentLength++;
                        disk.write(sector, data);
                    }
                }
            }
            reader.close();
            inputStream.close();
        } catch (Exception e) {e.printStackTrace();}
    }

    private void printFile(StringBuffer fileName) {
        FileInfo fi = directory.lookup(fileName);
        if (fi == null) {return;}
        StringBuffer data = new StringBuffer();
        for (int i = 0; i < fi.fileLength; i++) {
            data.setLength(0);
            disk.read(fi.startingSector + i, data);
            printer.print(data);
        }
    }
}
