using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using System.Data.SqlTypes;

namespace WindowsFormsApplication2
{
    class jodb
    {
        private SqlConnection polaczenie; //obiekt polaczenia widoczny w calej klasie

        /// <summary>
        /// konstruktor do tworzenia polaczenia za pomoca autoryzacji SQL Server 
        /// </summary>
        /// <param name="user">uzytkownik</param>
        /// <param name="pass">haslo</param>
        /// <param name="instance">nazwa instancji</param>
        /// <param name="dbdir">nazwa bazy danych</param>
        public jodb(string user, string pass, string instance, string dbdir)
        {
            polaczenie = new SqlConnection();
            polaczenie.ConnectionString = "user id=" + user + ";" +
            "password=" + pass + ";Data Source=" + instance + ";" +
            "Trusted_Connection=no;" +
            "database=" + dbdir + "; " +
            "connection timeout=3";
            polaczenie.Open();
        }
        /// <summary>
        /// konstruktor do tworzenia polaczenia za pomoca autoryzacji windows
        /// </summary>
        /// <param name="instance">nazwa instancji</param>
        /// <param name="dbdir">nazwa bazy danych</param>
        public jodb(string instance, string dbdir)
        {
            polaczenie = new SqlConnection();
            polaczenie.ConnectionString = "Data Source=" + instance + ";" +
            "Trusted_Connection=yes;" +
            "database=" + dbdir + "; " +
            "connection timeout=3";
            polaczenie.Open();
        }

        /// <summary>
        /// Metoda do pobierania danych z SQL Server
        /// </summary>
        /// <param name="q">zapytanie sql</param>
        /// <returns>zwraca dane w obiekcie DataTable</returns>
        /// 
        public DataTable pobierz_dane(string q)
        {
            DataTable dt = new DataTable(); // deklaracja i utworzenie instancji obiektu DataTable o nazwie dt
            SqlDataReader dr; // deklaracja obiektu SqlDataReader o nazwie dr
            SqlCommand sqlc; // Deklaracja obiektu SqlCOmmand

            sqlc = new SqlCommand(q);
            // utworzenie instancji SQLCommand ktora ma wykonac zapytanie podane jako parametr
            // w zmiennej q

            sqlc.Connection = this.polaczenie; // wskazanie polaczenia do bazy danych
            dr = sqlc.ExecuteReader(); //wykonanie zapytanie i utworzenie wskaznika dr
            dt.Load(dr); //zaladowanie danych do obiektu DataTAble
            return dt; // zwrocenie danych
        }
    }


}
