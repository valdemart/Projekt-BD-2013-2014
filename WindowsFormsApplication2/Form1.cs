using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WindowsFormsApplication2
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void pobieracz_Click(object sender, EventArgs e)
        {
            //jodb baza = new jodb("monika", "12345", ".", "wesela");
            jodb baza_win = new jodb("(local)", "wesela");
            dataGridView1.DataSource = baza_win.pobierz_dane("select * from osoby");
        }

    }
}
