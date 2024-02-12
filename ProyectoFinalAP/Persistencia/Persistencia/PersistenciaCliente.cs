using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
//--------------------------------
using System.Data.SqlClient;
using System.Data;
using EntidadesCompartidas;


namespace Persistencia
{
    internal class PersistenciaCliente: IPersistenciaCliente
    {
        //SINGLETON
        private static PersistenciaCliente instancia; //atributo de clase
        private PersistenciaCliente() { } //constructor privado

        public static PersistenciaCliente GetInstancia()
        {
            if (instancia == null)
                instancia = new PersistenciaCliente();

            return instancia;
        }
        //FIN SINGLETON

        //Buscar Cliente (Activo = 1)
        public Cliente BuscarCliente(string pNumPasaporte, Empleado pEmp)
        {
            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pEmp));
            SqlCommand cmd = new SqlCommand("sp_BuscarClienteActivo", oConexion);
            cmd.CommandType = CommandType.StoredProcedure;
            SqlParameter numPas = new SqlParameter("@NumPasaporte", pNumPasaporte);
            cmd.Parameters.Add(numPas);

            SqlDataReader dr;
            try
            {
                Cliente cliente = null;
                oConexion.Open();
                dr = cmd.ExecuteReader();

                if (dr.HasRows)
                {
                    dr.Read();
                    string numPasaporte = dr["NumPasaporte"].ToString();
                    string nombreCliente = dr["NombreCliente"].ToString();
                    string clientPass = dr["ClientPass"].ToString();
                    int numTarjeta = Convert.ToInt32(dr["NumTarjeta"]);
                    cliente = new Cliente(numPasaporte, nombreCliente, clientPass, numTarjeta);
                }
                dr.Close();
                return cliente;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                oConexion.Close();
            }
        }


        //Buscar Cliente 
        internal Cliente BuscarClienteTodos(string pNumPasaporte, Empleado pEmp)
        {
            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pEmp));
            SqlCommand cmd = new SqlCommand("sp_BuscarClienteTodos", oConexion);
            cmd.CommandType = CommandType.StoredProcedure;
            SqlParameter numPas = new SqlParameter("@NumPasaporte", pNumPasaporte);
            cmd.Parameters.Add(numPas);

            SqlDataReader dr;
            try
            {
                Cliente cliente = null;
                oConexion.Open();
                dr = cmd.ExecuteReader();

                if (dr.HasRows)
                {
                    dr.Read();
                    string numPasaporte = dr["NumPasaporte"].ToString();
                    string nombreCliente = dr["NombreCliente"].ToString();
                    string clientPass = dr["ClientPass"].ToString();
                    int numTarjeta = Convert.ToInt32(dr["NumTarjeta"]);
                    cliente = new Cliente(numPasaporte, nombreCliente, clientPass, numTarjeta);
                }

                dr.Close();
                return cliente;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                oConexion.Close();
            }
        }


        //Alta Cliente
        public void AltaCliente(Cliente pCliente, Empleado pEmp)
        {

            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pEmp));
            SqlCommand oComando = new SqlCommand("sp_AgregarCliente", oConexion);
            oComando.CommandType = CommandType.StoredProcedure;

            SqlParameter numPas = new SqlParameter("@NumPasaporte", pCliente.NumPasaporte);
            SqlParameter nomCli = new SqlParameter("@NombreCliente", pCliente.NombreCliente);
            SqlParameter cliPass = new SqlParameter("@ClientPass", pCliente.ClientPass);
            SqlParameter numTar = new SqlParameter("@NumTarjeta", pCliente.NumTarjeta);
            SqlParameter oRetorno = new SqlParameter("@retorno", SqlDbType.Int);
            oRetorno.Direction = ParameterDirection.ReturnValue;
            oComando.Parameters.Add(oRetorno);

            oComando.Parameters.Add(numPas);
            oComando.Parameters.Add(nomCli);
            oComando.Parameters.Add(cliPass);
            oComando.Parameters.Add(numTar);
            oComando.Parameters.Add(oRetorno);

            try
            {
                oConexion.Open();
                oComando.ExecuteNonQuery();

                int retorno = Convert.ToInt32(oRetorno.Value);

                if (retorno == -1)
                    throw new Exception("Error: el cliente ya existe");
                if (retorno == -2)
                    throw new Exception("Error inesperado");
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                oConexion.Close();
            }
        }


        //Modificar Cliente
        public void ModificarCliente(Cliente pCliente, Empleado pEmp)
        {
            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pEmp));
            SqlCommand cmd = new SqlCommand("sp_ModificarCliente", oConexion);
            cmd.CommandType = CommandType.StoredProcedure;

            SqlParameter numPas = new SqlParameter("@NumPasaporte", pCliente.NumPasaporte);
            SqlParameter nomCli = new SqlParameter("@NombreCliente", pCliente.NombreCliente);
            SqlParameter cliPass = new SqlParameter("@ClientPass", pCliente.ClientPass);
            SqlParameter numTar = new SqlParameter("@NumTarjeta", pCliente.NumTarjeta);
            SqlParameter retorno = new SqlParameter("@retorno", SqlDbType.Int);
            retorno.Direction = ParameterDirection.ReturnValue;

            int ret = 0;

            cmd.Parameters.Add(numPas);
            cmd.Parameters.Add(nomCli);
            cmd.Parameters.Add(cliPass);
            cmd.Parameters.Add(numTar);
            cmd.Parameters.Add(retorno);

            try
            {
                oConexion.Open();
                cmd.ExecuteNonQuery();
                ret = (int)cmd.Parameters["@retorno"].Value;
                if (ret == -1)
                    throw new Exception("Error al verificar datos del cliente");
                else if (ret != 1)
                    throw new Exception("Hubo un error inesperado en la modificación del cliente");
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                oConexion.Close();
            }
        }


        //Eliminar Cliente
        public void EliminarCliente(Cliente pCliente, Empleado pEmp)
        {
            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pEmp));
            SqlCommand cmd = new SqlCommand("sp_EliminarCliente", oConexion);
            cmd.CommandType = CommandType.StoredProcedure;

            SqlParameter codAP = new SqlParameter("@NumPasaporte", pCliente.NumPasaporte);
            SqlParameter retorno = new SqlParameter("@retorno", SqlDbType.Int);
            retorno.Direction = ParameterDirection.ReturnValue;

            int ret = 0;

            cmd.Parameters.Add(codAP);
            cmd.Parameters.Add(retorno);

            try
            {
                oConexion.Open();
                cmd.ExecuteNonQuery();
                ret = (int)cmd.Parameters["@retorno"].Value;
                if (ret == -1)
                    throw new Exception("Error al verificar datos de cliente");
                else if (ret != 1)
                    throw new Exception("Hubo un error inesperado en la eliminacion del cliente");
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                oConexion.Close();
            }
        }


        //Listar Clientes
        public List<Cliente> ListarClientes(Empleado pEmp)
        {
            List<Cliente> listaCliente = new List<Cliente>();
            string numPasaporte;
            string nombreCliente;
            string clientPass;
            int numTarjeta;

            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pEmp));
            SqlCommand oComando = new SqlCommand("listarClientes", oConexion);
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
                        numPasaporte = (string)oReader["NumPasaporte"];
                        nombreCliente = (string)oReader["NombreCliente"];
                        clientPass = (string)oReader["ClientPass"];
                        numTarjeta = (int)oReader["NumTarjeta"];

                        Cliente unCliente = new Cliente(numPasaporte, nombreCliente, clientPass, numTarjeta);
                        listaCliente.Add(unCliente);
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
            return listaCliente;
        }


    }
}
