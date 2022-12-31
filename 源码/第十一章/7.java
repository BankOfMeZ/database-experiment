import java.sql.*;

public class Transform {
  static final String JDBC_DRIVER = "org.postgresql.Driver";
    static final String DB_URL = "jdbc:postgresql://127.0.0.1:5432/postgres?";
    static final String USER = "gaussdb";
    static final String PASS = "Passwd123@123";
    
    /**
     * 向sc表中插入数据
     *
     */
    public static int insertSC(Connection connection, int sno, String col_name, int col_value){
      PreparedStatement preparedStatement = null;
      int n = 0;
      try {
        String sql = "insert into sc values (?, ?, ?);";
        preparedStatement = connection.prepareStatement(sql);
        preparedStatement.setInt(1, sno);
        preparedStatement.setString(2, col_name);
        preparedStatement.setInt(3, col_value);
        n = preparedStatement.executeUpdate();
      } catch (SQLException e) {
        e.printStackTrace();
      } finally {
        try {
          if (preparedStatement != null) {
            preparedStatement.close();
          }
        } catch (SQLException e) {
          e.printStackTrace();
        }
      }
      return n;
    }

    public static void main(String[] args) {
      Connection connection = null;
      Statement statement = null;
      ResultSet resultSet = null;
      try {
        Class.forName(JDBC_DRIVER);
        connection = DriverManager.getConnection(DB_URL, USER, PASS);
        statement = connection.createStatement();
        resultSet = statement.executeQuery("select * from entrance_exam;");
        while (resultSet.next()) {
          int sno = resultSet.getInt("sno"), t;
          if ((t = resultSet.getInt("chinese")) != 0) {
            insertSC(connection, sno, "chinese", t);
          }
          if ((t = resultSet.getInt("math")) != 0) {
            insertSC(connection, sno, "math", t);
          }
          if ((t = resultSet.getInt("english")) != 0) {
            insertSC(connection, sno, "english", t);
          }
          if ((t = resultSet.getInt("physics")) != 0) {
            insertSC(connection, sno, "physics", t);
          }
          if ((t = resultSet.getInt("chemistry")) != 0) {
            insertSC(connection, sno, "chemistry", t);
          }
          if ((t = resultSet.getInt("biology")) != 0) {
            insertSC(connection, sno, "biology", t);
          }
          if ((t = resultSet.getInt("history")) != 0) {
            insertSC(connection, sno, "history", t);
          }
          if ((t = resultSet.getInt("geography")) != 0) {
            insertSC(connection, sno, "geography", t);
          }
          if ((t = resultSet.getInt("politics")) != 0) {
            insertSC(connection, sno, "politics", t);
          }
        }
      } catch (ClassNotFoundException ce) {
        ce.printStackTrace();
      } catch (SQLException se) {
        se.printStackTrace();
      } finally {
        try {
          if (connection != null) {
            connection.close();
          }
          if (statement != null) {
            statement.close();
          }
          if (resultSet != null) {
            resultSet.close();
          }
        } catch (SQLException e) {
          e.printStackTrace();
        }
      }
    }
}