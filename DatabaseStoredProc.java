/*
 * DatabaseStoredProc.java
 *
 * Created on 08 May 2008, 17:09
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package com.omnifone.musicstation.server.web.stored_proc;

import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.jdbc.OracleConnection;
import oracle.jdbc.OracleCallableStatement;
import oracle.jdbc.OracleTypes;

// Utility that takes care of Oracle Connection 
import com.omnifone.musicstation.server.web.stored_proc.JDBCUtil;

// Database Logger
import com.omnifone.musicstation.server.ejb.billing.ExternalSubscriptionLogger;

/**
 *
 * @author mkaul
 */
public class DatabaseStoredProc {

    private static ExternalSubscriptionLogger logger =
            new ExternalSubscriptionLogger(DatabaseStoredProc.class.getCanonicalName());
    
    /** Creates a new instance of DatabaseStoredProc */
    public DatabaseStoredProc() {}

//    
//   public static void main(String[] args) throws SQLException
//  {  
//    _ProcedureBindByName();
//   }
//   
   
  public static void _ProcedureBindByName( )
    throws SQLException
  {
      
    System.out.println( "\n Oracle syntax, Calling a Procedure, Bind by name" );
    ResultSet rset                  = null;
    OracleCallableStatement cstmt   = null;
    OracleConnection conn           = null;
    
    try
    {
      // get connection - make sure you modify this call and
      // the JDBCUtil.getConnection() method to point to
      // your database, user and password.
      conn = (OracleConnection)JDBCUtil.getConnection("musicstation", "musicstation", "xe");
        
      // Formulate a callable statement string using Oracle style syntax
      String oracleBlock = 
        "begin  MKA_TEST_P.getObjects(?,?,?);  end;"; 
      
      // Prepare the CallableStatement object
      cstmt = (OracleCallableStatement)conn.prepareCall( oracleBlock );
      
      System.out.println("Binding Params");

      // Bind the input value by name
      cstmt.setString("pObjOwner", "PUBLIC" );
      cstmt.setString("pObjType", "SYNONYM" );
            
      // Register the output value cursor
      cstmt.registerOutParameter( "cObjectDetails", OracleTypes.CURSOR );
      System.out.println("Executing Query");
      // Execute the query
      cstmt.execute();
      rset = (ResultSet) cstmt.getObject( "cObjectDetails" );
      
      // Print the result 
      while (rset.next())
      {
        int objectID    = rset.getInt ( 3 );
        String objName  = rset.getString ( 2 );
        String objOwner = rset.getString ( 1 );
        
        logger.info("-- Result Set ----  ");
        logger.info("----------------------  ");
        logger.info( objectID + " <<<< " + objName + " <<<<  " + objOwner);
        System.out.println( objectID + " --- " + objName + " ---  " + objOwner );
      }
    }
    finally
    {
      // release JDBC resources in finally clause.
      JDBCUtil.close( rset );
      JDBCUtil.close( cstmt );
    }
  }
    
}
