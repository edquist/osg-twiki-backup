import java.io.*;
import java.util.*;

public class MountPoint implements gov.lbl.srm.policy.ISRMSelectionPolicy {
   String log_filename="/var/log/bestman2/servers.log";
   String server_filename="/etc/bestman2/conf/servers.txt";
   String defaultServer="ouhep0.nhn.ou.edu:2811";
   String currentString="";
   public void appendFile(String s) {
          FileOutputStream out; // declare a file output object
          PrintStream p; // declare a print stream object
          try
          {
                  // Create a new file output stream
                  out = new FileOutputStream(log_filename,true);
                  // Connect print stream to the output stream
                  p = new PrintStream( out );
                  p.println ((new java.util.Date()).getTime()+": "+s);
                  p.close();
          }
          catch (Exception e)
          {
                  System.err.println ("Error writing to test log file:"
			+log_filename);
          }
   }
   public Object getNext() {
       String server="";
       String thisLine;
       try {
		BufferedReader serverList = new BufferedReader(
			new FileReader(server_filename));
		while (((thisLine = serverList.readLine()) != null) &&server.equals(""))
		{ 
			String[] lines=thisLine.split("=");
			if (lines.length>=2)
			{
				if (currentString.contains(lines[0]))
				{
					server=lines[1];
				}
			}
		}
       }
       catch (Exception e)
	{
                System.err.println ("Error reading server file:"
			+server_filename);

	}
       if (server.equals(""))
	{
		server=defaultServer;
	}
       appendFile("Picked server ("+server+") from file for writing");
       return server;
   }
   public Object getNext(Object a) {
       appendFile("In the parent class for file: "+a);
	currentString=(String)a;
	return getNext();
   }
   public String[] displayContents() {
	String as[]={"gw014k1.fnal.gov:2811"};
       appendFile("In Display Contents");
	return as;
   }
   public void setItems(Object[] col) {
       appendFile("In set Items");
   }
}

