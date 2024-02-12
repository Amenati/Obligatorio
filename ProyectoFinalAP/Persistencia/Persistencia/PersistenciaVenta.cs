using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
//--------------------------------------
using System.Data.SqlClient;
using System.Data;
using EntidadesCompartidas;

namespace Persistencia  
{
    internal class PersistenciaVenta: IPersistenciaVenta  //SIN TERMINAR
    {
        //SINGLETON
        private static PersistenciaVenta instancia; //atributo de clase
        private PersistenciaVenta() { } //constructor privado

        public static PersistenciaVenta GetInstancia()
        {
            if (instancia == null)
                instancia = new PersistenciaVenta();

            return instancia;
        }
        //FIN SINGLETON



        public void AltaVenta(Venta pVenta, Empleado pEmp) //TRANSACCION LOGICA
        {

            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pEmp));

            SqlCommand oComando = new SqlCommand("AltaVenta", oConexion);
            oComando.CommandType = CommandType.StoredProcedure;
            oComando.Parameters.AddWithValue("@monto", pVenta.Monto);
            oComando.Parameters.AddWithValue("@usulog", pVenta.Empleado.UsuLog);
            oComando.Parameters.AddWithValue("@codigoVuelo", pVenta.Vuelo.CodigoVuelo);
            oComando.Parameters.AddWithValue("@numPasaporte", pVenta.Pagador.NumPasaporte);
          
            SqlParameter oRetorno = new SqlParameter("@Retorno", SqlDbType.Int);
            oRetorno.Direction = ParameterDirection.ReturnValue;
            oComando.Parameters.Add(oRetorno);
            SqlTransaction oTransaccion = null;

            try
            {
                oConexion.Open();
                oTransaccion = oConexion.BeginTransaction();
                oComando.ExecuteNonQuery();

                int retorno = Convert.ToInt32(oRetorno.Value);

                if (retorno == -1)
                    throw new Exception("Error: el empleado no existe");
                if (retorno == -2)
                    throw new Exception("Error: el vuelo no existe");
                if (retorno == -3)
                    throw new Exception("Error: el cliente no existe");
                if (retorno == -4)
                    throw new Exception("Error inesperado");

                foreach (Pasaje P in pVenta.Pasajes)
                {
                  PersistenciaPasaje.GetInstancia().AgregarPasaje(pVenta.NroVenta, P, oTransaccion);
                }

                oTransaccion.Commit();

            }
            catch (Exception ex)
            {
                oTransaccion.Rollback();
                throw ex;
            }
            finally
            {
                oConexion.Close();
            }
        }

        public List<Venta> ListarVentasVuelo(Vuelo pVuelo, Empleado pEmp)
        {
            List<Venta> listaVentas = new List<Venta>();
            int nroVenta;
            DateTime fechaCompra;
            int monto;
            Empleado empleado;
            Cliente pagador;
            List<Pasaje> pasajeros;


        SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pEmp));
            SqlCommand oComando = new SqlCommand("ListarVentasVuelo", oConexion);
            oComando.CommandType = CommandType.StoredProcedure;

            SqlDataReader oReader;

            try
            {
                oConexion.Open();
                oReader = oComando.ExecuteReader();
                //FALTA HAS ROWS!!!!EN TODOS LOS BUSCAR/LISTAR

                if (oReader.HasRows)
                {
                    while (oReader.Read())
                    {
                        nroVenta = (int)oReader["NroVenta"];
                        fechaCompra = (DateTime)oReader["FechaCompra"];
                        monto = (int)oReader["Monto"];
                        empleado = PersistenciaEmpleado.GetInstancia().BuscarEmpleado((string)oReader["Usulog"], pEmp);
                        pagador = PersistenciaCliente.GetInstancia().BuscarClienteTodos((string)oReader["NumPasaporte"], pEmp);
                        pasajeros = PersistenciaPasaje.GetInstancia().ListarPasajesVenta(nroVenta, pEmp);
                        Venta unaVenta = new Venta(nroVenta, fechaCompra, monto, empleado, pVuelo, pagador, pasajeros);
                        listaVentas.Add(unaVenta);
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

            return listaVentas;




        }


    }
}
