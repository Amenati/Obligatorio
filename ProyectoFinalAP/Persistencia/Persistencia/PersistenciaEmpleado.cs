using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
//----------------------------
using System.Data.SqlClient;
using System.Data;
using EntidadesCompartidas;

namespace Persistencia
{
    internal class PersistenciaEmpleado: IPersistenciaEmpleado
    {

        //SINGLETON
        private static PersistenciaEmpleado instancia; //atributo de clase
        private PersistenciaEmpleado() { } //constructor privado

        public static PersistenciaEmpleado GetInstancia()
        {
            if (instancia == null)
                instancia = new PersistenciaEmpleado();

            return instancia;
        }
        //FIN SINGLETON


        public Empleado BuscarEmpleado(string pUsulog, Empleado pLogueo)//pLogueo=empleado logueado
        {
            Empleado empleado = null;

            SqlConnection cnn = new SqlConnection(Conexion.Cnn(pLogueo)); 

            SqlCommand oComando = new SqlCommand("BuscarEmpleado", cnn);
            oComando.CommandType = CommandType.StoredProcedure;
            oComando.Parameters.AddWithValue("@nomUs", pUsulog);

            try
            {
                cnn.Open();
                SqlDataReader lector = oComando.ExecuteReader();

                if (lector.HasRows)
                {
                    lector.Read();
                    empleado = new Empleado(pUsulog, (string)lector["NombreUsu"], (string)lector["UsuPass"], (string)lector["Cargo"]);
                }

                lector.Close();

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                cnn.Close();
            }

            return empleado;
        }

        public void Logueo(Empleado pEmp) //Es operacion "publica", no paso Empleado logueado.
        {
            SqlConnection cnn = new SqlConnection(Conexion.Cnn());

            SqlCommand oComando = new SqlCommand("LogueoEmpleado", cnn);
            oComando.CommandType = CommandType.StoredProcedure;
            oComando.Parameters.AddWithValue("@usuLog", pEmp.UsuLog);
            oComando.Parameters.AddWithValue("@usuPass", pEmp.UsuPass);

            try
            {
                cnn.Open();
                SqlDataReader _lector = oComando.ExecuteReader();
                if (!_lector.HasRows)
                {
                    throw new Exception("Error - No es correcto el usuario y/o la contraseña");
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                cnn.Close();
            }
        }
    }
}
