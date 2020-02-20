using System;
using System.Text;
using MySql.Data.MySqlClient;

namespace flag_tool
{
    class Program
    {
        static void dumpMsgs(MySqlConnection con)
        {
            string sql = "SELECT * FROM message";
            using var cmd = new MySqlCommand(sql, con);

            using MySqlDataReader rdr = cmd.ExecuteReader();

            while (rdr.Read())
            {
                byte[] bytes = Encoding.ASCII.GetBytes(rdr.GetString(2));
                var encodedString = Encoding.UTF8.GetString(bytes);

                Console.WriteLine("{0} {1} {2} {3} {4}", 
                    rdr.GetInt32(0), 
                    rdr.GetInt32(1), 
                    encodedString, 
                    rdr.GetUInt64(3), 
                    rdr.GetInt32(4));
            }
        }

        static void flagMsg(int id, MySqlConnection con)
        {
            var query = $"UPDATE message SET flagged = 1 Where message_id = {id}";
            var command = new MySqlCommand(query, con);
            var res = command.ExecuteScalar();
            Console.WriteLine(res);
        }

        static void printHelp()
        {
            Console.WriteLine("Welcome to Minitwit-FlagTool");
            Console.WriteLine("You have two options");
            Console.WriteLine("To flag a request run: ");
            Console.WriteLine("     ./flag_tool f [ID]");
            Console.WriteLine("To inspect all messages run:");
            Console.WriteLine("     ./flag_tool i");
            Console.WriteLine("");
        }

        static void Main(string[] args)
        {
            if(args.Length == 0) 
            {
                printHelp();
                return;
            }

            var cs = @"server=172.17.0.2;userid=root;password=root;database=minitwit";
            using var con = new MySqlConnection(cs);
            try
            {
                con.Open();
                Console.WriteLine($"MySQL version : {con.ServerVersion}");

                if(args[0] == "i")
                {
                    dumpMsgs(con);
                }

                if(args[0] == "f" && args[1].Length > 1)
                {
                    flagMsg(int.Parse(args[1]), con);
                }

                Console.WriteLine();
            
            } 
            finally 
            {
                con.Close();
            }

        }
    }
}
