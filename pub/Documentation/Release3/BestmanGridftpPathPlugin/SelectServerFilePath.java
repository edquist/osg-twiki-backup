/**
 *
 * *** Copyright Notice ***
 *
 * BeStMan Copyright (c) 2010, The Regents of the University of California, 
 * through Lawrence Berkeley National Laboratory (subject to receipt of any 
 * required approvals from the U.S. Dept. of Energy).  This software was 
 * developed under funding from the U.S. Department of Energy and is 
 * associated with the Berkeley Lab Scientific Data Management Group projects.
 * All rights reserved.
 * 
 * If you have questions about your rights to use or distribute this software, 
 * please contact Berkeley Lab's Technology Transfer Department at TTD@lbl.gov.
 * 
 * NOTICE.  This software was developed under funding from the 
 * U.S. Department of Energy.  As such, the U.S. Government has been granted 
 * for itself and others acting on its behalf a paid-up, nonexclusive, 
 * irrevocable, worldwide license in the Software to reproduce, prepare 
 * derivative works, and perform publicly and display publicly.  
 * Beginning five (5) years after the date permission to assert copyright is 
 * obtained from the U.S. Department of Energy, and subject to any subsequent 
 * five (5) year renewals, the U.S. Government is granted for itself and others
 * acting on its behalf a paid-up, nonexclusive, irrevocable, worldwide license
 * in the Software to reproduce, prepare derivative works, distribute copies to
 * the public, perform publicly and display publicly, and to permit others to
 * do so.
 *
*/

/**
 *
 * Email questions to SRM@LBL.GOV
 * Scientific Data Management Research Group
 * Lawrence Berkeley National Laboratory
 * http://sdm.lbl.gov/bestman
 *
*/

package plugin;

//import EDU.oswego.cs.dl.util.concurrent.Mutex;
import java.util.*;

public class SelectServerFilePath implements gov.lbl.srm.policy.ISRMSelectionPolicy {
    int _count = -1;
    String[] _itemArray = null;
//ed++
    HashMap<String,Vector<String>> PathMap  = new HashMap<String,Vector<String>>();//map of path to servers
    HashMap<String,Integer> CountMap = new HashMap<String,Integer>();//map of path to count servers
    String firsttime = new String("first");
    Vector<String> ListOfPaths = new Vector<String>();
    String path = "";
//ed--
    java.io.File _file = null;
    long _lastChecked = -1;
    gov.lbl.srm.util.TSRMMutex _counterMutex = new gov.lbl.srm.util.TSRMMutex();

    public SelectServerFilePath(String filename) {       
	_file = new java.io.File(filename);
	if (!_file.exists()) {
	    throw new RuntimeException("File does not exist! name="+filename);
	}

	loadFile();
        firsttime="false";
    }

    public String[] displayContents() {
	if (!gov.lbl.srm.util.TSRMUtil.acquireSync(_counterMutex)) {
	    return null;
	}
	try {
	    doRefresh();
	    return _itemArray;
	} finally {
	    gov.lbl.srm.util.TSRMUtil.releaseSync(_counterMutex);	    
	}
    }

    //	read from file and verify that entries are valid protocols
    private void loadFile() {
	try {
	    java.io.BufferedReader input = new java.io.BufferedReader(new java.io.FileReader(_file.getCanonicalPath()));
	    //Vector items = new Vector();
	    
	    HashMap sorted = new HashMap();
	    while (input.ready()) {
			String currLine = input.readLine();
			if ((currLine == null) || (currLine.length() == 0)) {
				// skip;
				continue;
			} 
			if (currLine.charAt(0) == '#') {
			    //skip;
			} else {
			    gov.lbl.srm.server.TSRMTxfProtocol.checkProtocolWithCollection(currLine, sorted);
			}
	    }
	    if (sorted.size() > 1) {
			throw new RuntimeException("ProtocolFileFormat error: more than one type of protocols in one file!");
	    } else if (sorted.size() == 0) {
			throw new RuntimeException("ProtocolFileFormat error: No valid protocols found.");
	    }
	    Vector c = (Vector)(sorted.values().toArray()[0]);
	    
	    _itemArray = new String[c.size()];
	    for (int i=0; i<c.size(); i++) {
		_itemArray[i] =  c.get(i).toString();
//ed++
                 int posslash    = _itemArray[i].indexOf("/");
                 String hostPort = _itemArray[i].substring(0, posslash);
                 String mountpath= _itemArray[i].substring(hostPort.length()+1);
                 while (mountpath.endsWith("/")) {
                     mountpath = mountpath.substring(0, mountpath.length()-1);
                 }
                 mountpath = "/"+ mountpath;
                 if (!PathMap.containsKey(mountpath)) {
                    Vector<String> v = new Vector<String>();
                    v.add(hostPort);
                    PathMap.put(mountpath, v);
                 } else {
                    Vector<String> v = PathMap.get(mountpath);
                    if (!v.contains(hostPort)) {
                        v.add(hostPort);
                    }
                 }
                 //firstime only 
                 if (firsttime.equals("first")&&!CountMap.containsKey(mountpath)){
                  CountMap.put(mountpath,new Integer(-1));
                  ListOfPaths.addElement(mountpath);
                 }
                 System.out.println("hostPort:"+hostPort+" mount path:"+mountpath);
                 System.out.println("item Array["+i+"]"+_itemArray[i]);
//ed--
	    }
	    if (_count < 0) {
		_count = 0;
	    }
//ed++      
            System.out.println("size vector ListOfPaths:"+ListOfPaths.size());
            // Reset count for each Path that need
            for (int i=0; i<ListOfPaths.size(); i++) {
              int icount = CountMap.get( ListOfPaths.elementAt(i) );
              if (icount < 0 ){
                CountMap.put(ListOfPaths.elementAt(i),new Integer(0));
              }
            }
//ed--
	} catch (java.io.IOException e) {
	    e.printStackTrace();
	    throw new RuntimeException(e.getMessage());
	} 
	finally {}       
    } 
	
    public Object getNext(Object hint) {
//ed++
	path = (String)hint;
//ed--
//ed	String path = (String)hint;
        // do something about hostport selection
        // according to path
        // below is a sample selection algorithm that is not based on path
        //
        return getNext();
    }
    public Object getNext() {
	if (!gov.lbl.srm.util.TSRMUtil.acquireSync(_counterMutex)) {
	    return null;
	}

	try {
	    doRefresh();
	    
	    Object result = null;
	    
//ed++
             String pathselected = new String();
             for (int i=0;i<ListOfPaths.size(); i++) {
                 if (path.contains(ListOfPaths.elementAt(i)))
                 {
                   pathselected=ListOfPaths.elementAt(i);
                   break;
                 }
             }//loop of paths
             //choose default path if empty (first in list)
             if ((pathselected == null) || (pathselected.length() == 0)) {
                pathselected=ListOfPaths.elementAt(0);
             }
             int icount = CountMap.get( pathselected );
             Vector ListOfServers = (Vector)(PathMap.get(pathselected));
             if (( icount >=0 ) && (ListOfServers.size()>0) ){
                if (icount >= ListOfServers.size() ){
                   icount = ListOfServers.size() - 1;
                }
                result = ListOfServers.elementAt(icount);
                icount = icount + 1;
                icount = icount % (ListOfServers.size());
                CountMap.put(pathselected,icount);
             }
//ed--
//ed	    if ((_count >= 0) && (_itemArray != null)) {
//ed		if (_count >= _itemArray.length) {
//ed		    _count = _itemArray.length-1;
//ed		}
//ed		result = _itemArray[_count];
//ed		_count  = _count +1;
//ed		_count = _count % (_itemArray.length);
//ed	    }
	    return result;
	} finally {
	    gov.lbl.srm.util.TSRMUtil.releaseSync(_counterMutex);
	}
    }

    public void setItems(Object[] col) {
	/*	
	if (_itemArray == null) {
	    _itemArray = col;
	    _count = 0;
	}
	*/
    }

    private void doRefresh() {
	if (_file == null) {
	    return;
	}
	long lastModified = _file.lastModified();
	if (lastModified <= 0) {
	    return;
	}
	    
	if (lastModified < _lastChecked) {
	    return;
	}
	_lastChecked = lastModified;

	loadFile();
    }
}
