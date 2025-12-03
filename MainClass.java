import java.io.*;
import java.util.*;

public class MainClass {
    public static int NUM_USERS = 1;
    public static int NUM_DISKS = 1;
    public static int NUM_PRINTERS = 1;

    public static UserThread[] users;
    public static Disk[] disks;
    public static Printer[] printers;
    public static DiskManager diskManager;
    public static PrinterManager printerManager;
    public static DirectoryManager directoryManager;

    public static void main(String[] args) {
        if (args.length >= 3) {
            NUM_USERS = parseArg(args[0], 1);
            NUM_DISKS = parseArg(args[1], 1);
            NUM_PRINTERS = parseArg(args[2], 1);
        }

        directoryManager = new DirectoryManager();

        disks = new Disk[NUM_DISKS];
        for (int i = 0; i < NUM_DISKS; i++) {
            disks[i] = new Disk();
        }

        printers = new Printer[NUM_PRINTERS];
        try {
            for (int i = 0; i < NUM_PRINTERS; i++) {
                printers[i] = new Printer(i);
            }
        } catch (IOException e) {
            e.printStackTrace();
            return;
        }

        diskManager = new DiskManager(NUM_DISKS);
        printerManager = new PrinterManager(NUM_PRINTERS);

        users = new UserThread[NUM_USERS];
        for (int i = 0; i < NUM_USERS; i++) {
            users[i] = new UserThread(i);
        }

        for (int i = 0; i < NUM_USERS; i++) {
            users[i].start();
        }

        for (int i = 0; i < NUM_USERS; i++) {
            try {
                users[i].join();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        for (int i = 0; i < NUM_PRINTERS; i++) {
            try {
                printers[i].close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private static int parseArg(String s, int def) {
        try {
            if (s.startsWith("-")) s = s.substring(1);
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }
}

class Disk {
    static final int NUM_SECTORS = 2048;
    static final int DISK_DELAY = 80;
    StringBuffer[] sectors = new StringBuffer[NUM_SECTORS];

    Disk() {
        for (int i = 0; i < NUM_SECTORS; i++) {
            sectors[i] = new StringBuffer();
        }
    }

    void write(int sector, StringBuffer data) {
        try {
            Thread.sleep(DISK_DELAY);
        } catch (InterruptedException e) {
        }
        sectors[sector].setLength(0);
        sectors[sector].append(data.toString());
    }

    void read(int sector, StringBuffer data) {
        try {
            Thread.sleep(DISK_DELAY);
        } catch (InterruptedException e) {
        }
        data.setLength(0);
        data.append(sectors[sector].toString());
    }
}

class Printer {
    static final int PRINT_DELAY = 275;
    private final BufferedWriter output;

    Printer(int id) throws IOException {
        output = new BufferedWriter(new FileWriter("PRINTER" + id));
    }

    synchronized void print(StringBuffer data) {
        try {
            Thread.sleep(PRINT_DELAY);
            output.write(data.toString());
            output.newLine();
            output.flush();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    void close() throws IOException {
        output.close();
    }
}

class FileInfo {
    int diskNumber;
    int startingSector;
    int fileLength;
}

class DirectoryManager {
    private Hashtable<String, FileInfo> T = new Hashtable<String, FileInfo>();

    void enter(StringBuffer fileName, FileInfo file) {
        T.put(fileName.toString(), file);
    }

    FileInfo lookup(StringBuffer fileName) {
        return T.get(fileName.toString());
    }
}

class ResourceManager {
    boolean[] isFree;

    ResourceManager(int numberOfItems) {
        isFree = new boolean[numberOfItems];
        for (int i = 0; i < isFree.length; ++i)
            isFree[i] = true;
    }

    synchronized int request() {
        while (true) {
            for (int i = 0; i < isFree.length; ++i) {
                if (isFree[i]) {
                    isFree[i] = false;
                    return i;
                }
            }
            try {
                this.wait();
            } catch (InterruptedException e) {
            }
        }
    }

    synchronized void release(int index) {
        isFree[index] = true;
        this.notify();
    }
}

class DiskManager extends ResourceManager {
    private int[] nextFreeSector;

    DiskManager(int numDisks) {
        super(numDisks);
        nextFreeSector = new int[numDisks];
        for (int i = 0; i < numDisks; i++) {
            nextFreeSector[i] = 0;
        }
    }

    synchronized int allocateSectors(int diskNum, int fileLength) {
        int start = nextFreeSector[diskNum];
        nextFreeSector[diskNum] += fileLength;
        return start;
    }
}

class PrinterManager extends ResourceManager {
    PrinterManager(int numberOfPrinters) {
        super(numberOfPrinters);
    }
}

class UserThread extends Thread {
    private final int userId;
    private final ArrayList<PrintJobThread> printJobs = new ArrayList<PrintJobThread>();

    UserThread(int userId) {
        this.userId = userId;
    }

    public void run() {
        processUserCommands();
        for (PrintJobThread job : printJobs) {
            try {
                job.join();
            } catch (InterruptedException e) {
            }
        }
    }

    private void processUserCommands() {
        String userFileName = "USER" + userId;
        try (BufferedReader reader = new BufferedReader(new FileReader(userFileName))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.startsWith(".save")) {
                    handleSave(line, reader);
                } else if (line.startsWith(".print")) {
                    handlePrint(line);
                }
            }
        } catch (IOException e) {
        }
    }

    private void handleSave(String firstLine, BufferedReader reader) throws IOException {
        String[] parts = firstLine.split("\\s+");
        if (parts.length < 2) return;
        String fileNameString = parts[1];

        ArrayList<StringBuffer> dataLines = new ArrayList<StringBuffer>();
        String line;
        while ((line = reader.readLine()) != null && !line.equals(".end")) {
            dataLines.add(new StringBuffer(line));
        }

        int fileLength = dataLines.size();
        int diskNum = MainClass.diskManager.request();
        try {
            int start = MainClass.diskManager.allocateSectors(diskNum, fileLength);
            Disk d = MainClass.disks[diskNum];
            for (int i = 0; i < fileLength; i++) {
                d.write(start + i, dataLines.get(i));
            }
            FileInfo info = new FileInfo();
            info.diskNumber = diskNum;
            info.startingSector = start;
            info.fileLength = fileLength;
            MainClass.directoryManager.enter(new StringBuffer(fileNameString), info);
        } finally {
            MainClass.diskManager.release(diskNum);
        }
    }

    private void handlePrint(String line) {
        String[] parts = line.split("\\s+");
        if (parts.length < 2) return;
        StringBuffer fname = new StringBuffer(parts[1]);
        if (MainClass.directoryManager.lookup(fname) == null) return;
        PrintJobThread job = new PrintJobThread(fname);
        printJobs.add(job);
        job.start();
    }
}

class PrintJobThread extends Thread {
    private final StringBuffer fileName;

    PrintJobThread(StringBuffer fileName) {
        this.fileName = new StringBuffer(fileName.toString());
    }

    public void run() {
        FileInfo info = MainClass.directoryManager.lookup(fileName);
        if (info == null || info.fileLength == 0) return;

        int printerIndex = MainClass.printerManager.request();
        try {
            Printer printer = MainClass.printers[printerIndex];
            Disk disk = MainClass.disks[info.diskNumber];
            StringBuffer buffer = new StringBuffer();
            for (int i = 0; i < info.fileLength; i++) {
                buffer.setLength(0);
                disk.read(info.startingSector + i, buffer);
                printer.print(buffer);
            }
        } finally {
            MainClass.printerManager.release(printerIndex);
        }
    }
}
