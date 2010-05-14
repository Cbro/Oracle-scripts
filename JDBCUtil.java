/*
 * JDBCUtil.java
 *
 * Created on 08 May 2008, 14:28
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package com.omnifone.musicstation.server.web.stored_proc;

import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.SQLWarning;
import java.util.Properties;
import oracle.jdbc.pool.OracleDataSource;

/**
 *
 * @author mkaul
 */
public class JDBCUtil {
    
    /** Creates a new instance of JDBCUtil */
    public JDBCUtil() {
    }
    
    /*
   public static void main(String[] args) throws SQLException
  {  
    Connection conn = getConnection( "musicstation", "musicstation", "xe" );
    Statement stmt = conn.createStatement();
    ResultSet rset = stmt.executeQuery("select count(*) from dual" );
    while( rset.next() )
    {
      System.out.println( "Result Coming in from XE ----> " + rset.getInt(1) );
    }
  } 
*/
  public static Connection getConnection( String username, String password, String dbName)
    throws SQLException
  {
    OracleDataSource ods    = null;
    Connection connection   = null;
    boolean exceptionRaised = false;
    
    // Create a new Oracle Data Source
    ods = new OracleDataSource();
    
    // set the properties that define the connection
    ods.setDriverType ( "oci" );            // type of driver
    ods.setServerName ( "localhost" );      // database server name
    ods.setNetworkProtocol("tcp");          // tcp is the default anyway
    ods.setDatabaseName(dbName);            // Oracle SID
    ods.setPortNumber(1521);
    
    ods.setUser(username);                  // user name
    ods.setPassword(password);              // password
    
    System.out.println( "URL:" + ods.getURL());
    System.out.flush();
   
    connection = ods.getConnection();
    connection.setAutoCommit( false );
    return connection;
  }

  public static void close ( ResultSet resultSet, Statement statement,
    Connection connection )
  {
    try
    {
      if( resultSet != null )
        resultSet.close();
      if( statement != null )
        statement.close();
      if( connection != null )
        connection.close();
    }
    catch ( SQLException ignored ) { }

  }

  public static void close ( ResultSet resultSet, Statement statement )
  {
    try
    {
      if( resultSet != null )
        resultSet.close();
      if( statement != null )
        statement.close();
    }
    catch ( SQLException ignored ) { }
  }

  public static void close ( ResultSet resultSet )
  {
    try
    {
      if( resultSet != null )
        resultSet.close();
    }
    catch ( SQLException ignored ) { }

  }

  public static void close ( Statement statement )
  {
    try
    {
      if( statement != null )
        statement.close();
    }
    catch ( SQLException ignored ) { }

  }

  public static void close ( Connection connection )
  {
    try
    {
      if( connection != null )
        connection.close();
    }
    catch ( SQLException ignored ) { }
  }

  public static void printException ( Exception e )
  {
    System.out.println ("Exception caught! Exiting .." );
    System.out.println ("error message: " + e.getMessage() );
    e.printStackTrace();
  }

  public static void printExceptionAndRollback ( Connection conn,
    Exception e )
  {
    printException ( e );
    try { if( conn != null ) conn.rollback(); } catch (SQLException ignore) {}
  }
  
   
   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
