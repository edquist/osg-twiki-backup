package edu.unl.dCache.poolManager;
import java.util.Map;
import java.util.Iterator;
import diskCacheV111.pools.CostCalculatable;
import diskCacheV111.pools.PoolCostInfo;

public class CostCalculationV1 implements CostCalculatable, java.io.Serializable{

    /**
	 * Eclipse generated serialVersionUID
	 */
	private static final long serialVersionUID = -1709677654627223484L;
	private PoolCostInfo      _info = null;
    private double _performanceCost = 0.0;
    private double _spaceCost       = 0.0;
    private PoolCostInfo.PoolSpaceInfo _space = null;
    
    public CostCalculationV1( PoolCostInfo info ){
       _info  = info;
       _space = _info.getSpaceInfo();
    }
    
    public double getSpaceCost(){
       return _spaceCost;
    }
    
    public double getPerformanceCost(){
       return _performanceCost;
    }
    
    public void recalculate( long filesize ){
          
       filesize = Math.max( filesize , 1048576000 ); // Max of filesize and 1GB

       long gap = _space.getGap();
       long freespace = _space.getFreeSpace();
       long totalspace = _space.getTotalSpace();
       if (freespace-2*filesize < gap) { _spaceCost = 2000000000; }
       else {
    	   _spaceCost = (1 + (totalspace - freespace + filesize) / totalspace + .1 * Math.random());
       }
       
       double cost = 0.0;
       double div  = 0.0 ;

       PoolCostInfo.PoolQueueInfo queue = null;

       Map map = _info.getExtendedMoverHash();
       
       double poolCapability = 0;
       
       try {
    	   poolCapability = _info.getStoreQueue().getMaxActive();
       } catch (Exception e) {
    	   System.err.println("Error getting store queue in cost calculator!\n");
       }
       
       if (poolCapability == 0) poolCapability = 20;
       
       if (map == null) {
    	   queue = _info.getMoverQueue();
    	   cost += ( ((double)queue.getActive()) / poolCapability);
    	   div += 1.0;
       }

       if( map != null )
       for( Iterator it = map.values().iterator(); it.hasNext(); ){
          queue = (PoolCostInfo.PoolQueueInfo)it.next();
          if( ( queue != null ) && ( queue.getMaxActive() > 0 ) ){
            cost += (double)queue.getActive() / poolCapability ;
            div += 1.0;
          }
       }
       
       cost = Math.pow(cost,3) + .1 * Math.random();
       
       _performanceCost = (div > 0.0) ? cost / div : 2000000000.0;


    }

}
