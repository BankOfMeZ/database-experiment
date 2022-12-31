import java.sql.*;
import java.util.Scanner;

public class AddClient {
    static final String JDBC_DRIVER = "org.postgresql.Driver";
    static final String DB_URL = "jdbc:postgresql://127.0.0.1:5432/postgres?";
    static final String USER = "gaussdb";
    static final String PASS = "Passwd123@123";
    
    /**
     * 向Client表中插入数据
     *
     * @param connection 数据库连接对象
     * @param c_id 客户编号
     * @param c_name 客户名称
     * @param c_mail 客户邮箱
     * @param c_id_card 客户身份证
     * @param c_phone 客户手机号
     * @param c_password 客户登录密码
     */
    public static int insertClient(Connection connection,
                                   int c_id, String c_name, String c_mail,
                                   String c_id_card, String c_phone, 
                                   String c_password){
        int n = 0;
        PreparedStatement preparedStatement = null;
        try {
            String sql = "insert into client values (?, ?, ?, ? ,? , ?)";
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, c_id);
            preparedStatement.setString(2, c_name);
            preparedStatement.setString(3, c_mail);
            preparedStatement.setString(4, c_id_card);
            preparedStatement.setString(5, c_phone);
            preparedStatement.setString(6, c_password);
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

    // 不要修改main() 
    public static void main(String[] args) throws Exception {

        Scanner sc = new Scanner(System.in);
        Class.forName(JDBC_DRIVER);

        Connection connection = DriverManager.getConnection(DB_URL, USER, PASS);

        while(sc.hasNext())
        {
            String input = sc.nextLine();
            if(input.equals(""))
                break;

            String[]commands = input.split(" ");
            if(commands.length ==0)
                break;
            int id = Integer.parseInt(commands[0]);
            String name = commands[1];
            String mail = commands[2];
            String idCard = commands[3];
            String phone = commands[4];
            String password = commands[5];

            insertClient(connection, id, name, mail, idCard, phone, password);
        }
    }

}
