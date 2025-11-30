import java.io.*;
import java.util.*;

public class MainClass 
{
    public static int NUM_USERS = 1;
    public static int NUM_DISKS = 1;
    public static int NUM_PRINTERS = 1;

    public static UserThread[] users;
    public static Disk[] disks;
    public static Printer[] printers;
    public static DiskManager diskManager;
    public static PrinterManager printerManager;
    public static DirectoryManager directoryManager;

    public static void main(String[] args)
    {
        if (args.length == 3)
        {
            try 
            {
                NUM_USERS = Integer.parseInt(args[0].replace("-", ""));
                NUM_DISKS = Integer.parseInt(args[1].replace("-", ""));
                NUM_PRINTERS = Integer.parseInt(args[2].replace("-", ""));
            } catch (NumberFormatException e) 
            {
                System.out.println("Invalid arguments. Using defaults: 1 User, 1 Disk, 1 Printer");
            }
        }

        directoryManager = new DirectoryManager(); 
        
        disks = new Disk[NUM_DISKS];
        for (int i = 0; i < NUM_DISKS; i++)
        {
            disks[i] = new Disk();
        }

        printers = new Printer[NUM_PRINTERS];
        for (int i = 0; i < NUM_PRINTERS; i++)
        {
            printers[i] = new Printer(i);
        }

        diskManager = new DiskManager(NUM_DISKS);
        printerManager = new PrinterManager(NUM_PRINTERS);

        users = new UserThread[NUM_USERS];
        for (int i = 0; i < NUM_USERS; i++)
        {
            users[i] = new UserThread(i);
        }

        for (int i = 0; i < NUM_USERS; i++)
        {
            users[i].start();
        }

        for (int i = 0; i < NUM_USERS; i++)
        {
            try 
            {
                users[i].join();
            } catch (InterruptedException e)
            {
                e.printStackTrace();
            }
        }
        System.out.println("Simulation Complete.");
    }
}

class Disk {
    static final int NUM_SECTORS = 2048;
    static final int DISK_DELAY = 80;

    StringBuffer sectors[] = new StringBuffer[NUM_SECTORS];

    public Disk(){
        for(int i = 0; i < NUM_SECTORS; i++){
            sectors[i] = new StringBuffer();
        }
    }

    void write(int sector, StringBuffer data) {
        try {
            Thread.sleep(DISK_DELAY);
        } catch (InterruptedException e){

        }
        sectors[sector].setLength(0);
        sectors[sector].append(data);
    }

    void read(int sector, StringBuffer data)
    {
        try {
            Thread.sleep(DISK_DELAY);
        } catch (InterruptedException e) {

        }
        data.setLength(0);
        data.append(sectors[sector]);
    }
}

class Printer {
    static final int PRINT_DELAY = 275;
    private int iden;
    private BufferedWriter output;

    Printer(int iden) {
        this.iden = iden;
        try {
            output = new BufferedWriter(new FileWriter("PRINTER" + iden));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    void print(StringBuffer data)
    {
        try {
            Thread.sleep(PRINT_DELAY);
            output.write(data.toString());
            output.newLine();
            output.flush();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}

class FileInfo{
    int diskNumber;
    int startingSector;
    int fileLength;
}

class DirectoryManager {
    private Hashtable<String, FileInfo> T = 
        new Hashtable<String, FileInfo>();

    void enter(String fileName, FileInfo file) {
        T.put(fileName, file);
    }

    FileInfo lookup(String fileName) {
        return T.get(fileName);
    }
}

class ResourceManager {
    boolean isFree[];
    ResourceManager(int numberOfItems) {
        isFree = new boolean[numberOfItems];
        for(int i = 0; i < isFree.length; ++i)
            isFree[i] = true;
    }

    synchronized int request() {
        while(true){
            for(int i = 0; i < isFree.length; ++i)
                if(isFree[i]) {
                    isFree[i] = false;
                    return i;
                }
            try {
                this.wait();
            } catch (InterruptedException e){

            }
        }
    }

    synchronized void release(int index) {
        isFree[index] = true;
        this.notify();
    }
}

class DiskManager extends ResourceManager {
    private int[] freeSector;

    DiskManager(int numDisks) {
        super(numDisks);
        freeSector = new int[numDisks];
        for (int i = 0; i < numDisks; i++) {
            freeSector[i] = 0;
        }
    }

    synchronized int allocateSectors(int disknum, int filelen) {
        int start = freeSector[disknum];
        freeSector[disknum] += filelen;
        return start;
    }
}

class PrinterManager extends ResourceManager {
    PrinterManager(int numberOfPrinters) {
        super(numberOfPrinters);
    }
}

class UserThread extends Thread {
    int userId;
    String fileName;

    private ArrayList<PrintJobThread> printJobs = new ArrayList<>();

    UserThread(int userId) {
        this.userId = userId;
        this.fileName = "USER" + userId;
    }

    public void run()
    {
        processUserCommands();
        for (PrintJobThread job: printJobs) {
            try {
                job.join();
            } catch (InterruptedException e){
            }
        }
    }

    private void processUserCommands() {
        try (BufferedReader buffer = new BufferedReader(new FileReader(fileName))) {
            String line;
            while ((line = buffer.readLine()) != null) {
                if(line.startsWith(".save")) {
                    String[] parts = line.split("\\s+");
                    if (parts.length < 2) continue;
                    String fname = parts[1];

                    ArrayList<StringBuffer> data = new ArrayList<>();
                    while ((line = buffer.readLine()) != null && !line.equals(".end")) {
                        data.add(new StringBuffer(line));
                    }

                    int fileLength = data.size();
                    if (fileLength == 0) {
                        FileInfo empty = new FileInfo();
                        empty.diskNumber = 0;
                        empty.startingSector = 0;
                        empty.fileLength = 0;
                        MainClass.directoryManager.enter(fname, empty);
                        continue;
                    }

                    int diskNum = MainClass.diskManager.request();
                    try {
                        int start = MainClass.diskManager.allocateSectors(diskNum, fileLength);
                        Disk d = MainClass.disks[diskNum];

                        for(int i = 0; i < fileLength; i++) {
                            d.write(start + i, data.get(i));
                        }

                        FileInfo info = new FileInfo();
                        info.diskNumber = diskNum;
                        info.startingSector = start;
                        info.fileLength = fileLength;
                        MainClass.directoryManager.enter(fname, info);

                    } finally {
                        MainClass.diskManager.release(diskNum);
                    }
                }
                else if(line.startsWith(".print")) {
                    String[] part = line.split("\\s+");
                    if (part.length < 2) continue;

                    String fname = part[1];
                    FileInfo info = MainClass.directoryManager.lookup(fname);
                    if (info != null) {
                        PrintJobThread job = new PrintJobThread(info);
                        printJobs.add(job);
                        job.start();
                    }
                }
            }
        } catch (IOException e) {
        }
    }
}

class PrintJobThread extends Thread {
    private FileInfo info;

    PrintJobThread(FileInfo info) {
        this.info = info;
    }

    public void run() {
        int printerIndex = MainClass.printerManager.request();
        try {
            Printer print = MainClass.printers[printerIndex];
            Disk dis = MainClass.disks[info.diskNumber];

            StringBuffer buffer = new StringBuffer();
            for(int i = 0; i < info.fileLength; i++){
                dis.read(info.startingSector + i, buffer);
                print.print(buffer);
            }
        } finally {
            MainClass.printerManager.release(printerIndex);
        }
    }
}
