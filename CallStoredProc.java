/*
 * CallStoredProc.java
 *
 * Created on 08 May 2008, 12:44
 */

package com.omnifone.musicstation.server.web.stored_proc;

import java.io.*;
import java.net.*;
import java.sql.SQLException;

import javax.servlet.*;
import javax.servlet.http.*;

// Import my Classes
import com.omnifone.musicstation.server.web.stored_proc.JDBCUtil;
import com.omnifone.musicstation.server.web.stored_proc.DatabaseStoredProc;

/**
 *
 * @author mkaul
 * @version
 */
public class CallStoredProc extends HttpServlet {
    
    /** Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servlet request
     * @param response servlet response
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        /* TODO output your page here */
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Servlet CallStoredProc</title>");
        out.println("</head>");
        out.println("<body>");
        out.println("<h1> ---- Servlet CallStoredProc at " + request.getContextPath () + "</h1>");
        
        // Call the stored Procedure immediately after!
        try 
        {
                DatabaseStoredProc._ProcedureBindByName();
   
        } catch (SQLException e)
        {
          // print a message and rollback.
          out.println("<h2> ---- Procedure Failed !! --- </h2>");  
        }
    finally
    {}
        out.println("<h2> ---- Procedure Successful  !! --- </h2>");  
        out.println("</body>");
        out.println("</html>");
        out.close();
    }
    
    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }
    
    /** Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }
    
    /** Returns a short description of the servlet.
     */
    public String getServletInfo() {
        return "Short description";
    }
    // </editor-fold>
}
