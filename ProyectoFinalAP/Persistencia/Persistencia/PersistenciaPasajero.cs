using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
//--------------------------------
using System.Data.SqlClient;
using System.Data;
using EntidadesCompartidas;

namespace Persistencia   //SIN TERMINAR //TRANSACCION LOGICA PASAJERO>VENTA
    //Operacion INTERNAL
{
    internal class PersistenciaPasaje //Concepto dependiente no implementa Interface
    {
        //SINGLETON
        private static PersistenciaPasaje instancia; //atributo de clase
        private PersistenciaPasaje() { } //constructor privado

        public static PersistenciaPasaje GetInstancia()
        {
            if (instancia == null)
                instancia = new PersistenciaPasaje();

            return instancia;
        }
        //FIN SINGLETON


        internal void AgregarPasaje(int nroVenta, Pasaje pPasajero, SqlTransaction trn) //Transaccion logica
        {
    
            SqlCommand oComando = new SqlCommand("AltaPasajero", trn.Connection);
            oComando.CommandType = CommandType.StoredProcedure;
            oComando.Parameters.AddWithValue("@nroVenta", nroVenta);
            oComando.Parameters.AddWithValue("@numPasaporte", pPasajero.Cliente.NumPasaporte);
            oComando.Parameters.AddWithValue("@nroAsiento", pPasajero.NroAsiento);
          
            SqlParameter oRetorno = new SqlParameter("@Retorno", SqlDbType.Int);
            oRetorno.Direction = ParameterDirection.ReturnValue;
            oComando.Parameters.Add(oRetorno);

            try
            {
                oComando.Transaction = trn;
                oComando.ExecuteNonQuery();

                int retorno = Convert.ToInt32(oRetorno.Value);

                if (retorno == -1)
                    throw new Exception("Error: el pasajero ya existe");
                if (retorno == -2)
                    throw new Exception("Error: la venta no existe");
                if (retorno == -3)
                    throw new Exception("Error: el cliente no existe");
                if (retorno == -4)
                    throw new Exception("Error inesperado");

            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        internal List<Pasaje> ListarPasajesVenta(int nroVenta, Empleado pEmp) 
        {
            List<Pasaje> listaPasajero = new List<Pasaje>();

            int nroAsiento;
            Cliente cliente;

            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pEmp));
            SqlCommand oComando = new SqlCommand("ListarPasajeros", oConexion);
            oComando.CommandType = CommandType.StoredProcedure;

            SqlDataReader oReader;

            try
            {
                oConexion.Open();
                oReader = oComando.ExecuteReader();
                if (oReader.HasRows)
                {
                    while (oReader.Read())
                    {
                        nroAsiento = (int)oReader["NroAsiento"];
                        cliente = PersistenciaCliente.GetInstancia().BuscarClienteTodos((string)oReader["NumPasaporte"], pEmp);
                        Pasaje unPasaje = new Pasaje(nroAsiento, cliente);
                        listaPasajero.Add(unPasaje);

                    }
                }
                
                oReader.Close();
 
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }

            finally
            {
                oConexion.Close();
            }

            return listaPasajero;

        }

    }
}
