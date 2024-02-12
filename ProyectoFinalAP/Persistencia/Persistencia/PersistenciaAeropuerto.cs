using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
//------------------------------
using System.Data.SqlClient;
using System.Data;
using EntidadesCompartidas;

namespace Persistencia
{
    internal class PersistenciaAeropuerto: IPersistenciaAeropuerto
    {

        //SINGLETON
 
        private static PersistenciaAeropuerto instancia; //atributo de clase
        private PersistenciaAeropuerto() { } //constructor privado

        public static PersistenciaAeropuerto GetInstancia()
        {
            if (instancia == null)
                instancia = new PersistenciaAeropuerto();

            return instancia;
        }
        //FIN SINGLETON


        //Buscar Aeropuerto (Activo = 1)
        public Aeropuerto BuscarAeropuerto(string pCodigoAP, Empleado pEmp)
        {
            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pEmp));
            SqlCommand cmd = new SqlCommand("sp_BuscarAeropuertoActivo", oConexion);
            cmd.CommandType = CommandType.StoredProcedure;
            SqlParameter codAP = new SqlParameter("@CodigoAP", pCodigoAP);
            cmd.Parameters.Add(codAP);

            SqlDataReader dr;
            try
            {
                Aeropuerto aeropuerto = null;
                oConexion.Open();
                dr = cmd.ExecuteReader();

                if (dr.HasRows)
                {
                    dr.Read();
                    string CodigoAP = dr["CodigoAP"].ToString();
                    int ImpLlegada = Convert.ToInt32(dr["ImpLlegada"]);
                    int ImpPartida = Convert.ToInt32(dr["ImpPartida"]);
                    string NombreAP = dr["NombreAP"].ToString();
                    string Direccion = dr["Direccion"].ToString();
                    Ciudad CodigoCiudad = PersistenciaCiudad.GetInstancia().BuscarCiudad(dr["CodigoCiudad"].ToString(),pEmp);
                    aeropuerto = new Aeropuerto(CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad);
                }
                dr.Close();
                return aeropuerto;
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


        //Buscar Aeropuerto
        internal Aeropuerto BuscarAeropuertoTodos(string pCodigoAP, Empleado pEmp)
        {
            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pEmp));
            SqlCommand cmd = new SqlCommand("sp_BuscarAeropuertoTodos", oConexion);
            cmd.CommandType = CommandType.StoredProcedure;
            SqlParameter codAP = new SqlParameter("@CodigoAP", pCodigoAP);
            cmd.Parameters.Add(codAP);

            SqlDataReader dr;
            try
            {
                Aeropuerto aeropuerto = null;
                oConexion.Open();
                dr = cmd.ExecuteReader();

                if (dr.HasRows)
                {
                    dr.Read();
                    string CodigoAP = dr["CodigoAP"].ToString();
                    int ImpLlegada = Convert.ToInt32(dr["ImpLlegada"]);
                    int ImpPartida = Convert.ToInt32(dr["ImpPartida"]);
                    string NombreAP = dr["NombreAP"].ToString();
                    string Direccion = dr["Direccion"].ToString();
                    Ciudad CodigoCiudad = PersistenciaCiudad.GetInstancia().BuscarCiudad(dr["CodigoCiudad"].ToString(),pEmp);
                    aeropuerto = new Aeropuerto(CodigoAP, ImpLlegada, ImpPartida, NombreAP, Direccion, CodigoCiudad);
                }
                dr.Close();
                return aeropuerto;
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


        //Alta Aeropuerto
        public void AltaAeropuerto(Aeropuerto pAeropuerto, Empleado pEmp)
        {
            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pEmp));
            SqlCommand oComando = new SqlCommand("sp_AgregarAeropuerto", oConexion);
            oComando.CommandType = CommandType.StoredProcedure;

            SqlParameter codAP = new SqlParameter("@CodigoAP", pAeropuerto.CodigoAP);
            SqlParameter dir = new SqlParameter("@Direccion", pAeropuerto.Direccion);
            SqlParameter impLlegada = new SqlParameter("@ImpLlegada", pAeropuerto.ImpLlegada);
            SqlParameter impPartida = new SqlParameter("@ImpPartida", pAeropuerto.ImpPartida);
            SqlParameter nomAP = new SqlParameter("@NombreAP", pAeropuerto.NombreAP);
            SqlParameter codCiu = new SqlParameter("@CodigoCiudad", pAeropuerto.Ciudad.CodigoCiudad);
            SqlParameter oRetorno = new SqlParameter("@retorno", SqlDbType.Int);
            oRetorno.Direction = ParameterDirection.ReturnValue;
            oComando.Parameters.Add(oRetorno);

            oComando.Parameters.Add(codAP);
            oComando.Parameters.Add(dir);
            oComando.Parameters.Add(impLlegada);
            oComando.Parameters.Add(impPartida);
            oComando.Parameters.Add(nomAP);
            oComando.Parameters.Add(codCiu);
            oComando.Parameters.Add(oRetorno);

            try
            {
                oConexion.Open();
                oComando.ExecuteNonQuery();

                int retorno = Convert.ToInt32(oRetorno.Value);

                if (retorno == -1)
                    throw new Exception("Error: el aeropuerto ya existe");
                if (retorno == -2)
                    throw new Exception("Error: la ciudad no existe");
                if (retorno == -3)
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


        //Modificar Aeropuerto
        public void ModificarAeropuerto(Aeropuerto pAeropuerto, Empleado pEmp)
        {
            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pEmp));
            SqlCommand cmd = new SqlCommand("sp_ModificarAeropuerto", oConexion);
            cmd.CommandType = CommandType.StoredProcedure;

            SqlParameter codAP = new SqlParameter("@CodigoAP", pAeropuerto.CodigoAP);
            SqlParameter dir = new SqlParameter("@Direccion", pAeropuerto.Direccion);
            SqlParameter impLlegada = new SqlParameter("@ImpLlegada", pAeropuerto.ImpLlegada);
            SqlParameter impPartida = new SqlParameter("@ImpPartida", pAeropuerto.ImpPartida);
            SqlParameter nomAP = new SqlParameter("@NombreAP", pAeropuerto.NombreAP);
            SqlParameter codCiu = new SqlParameter("@CodigoCiudad", pAeropuerto.Ciudad.CodigoCiudad);
            SqlParameter retorno = new SqlParameter("@retorno", SqlDbType.Int);
            retorno.Direction = ParameterDirection.ReturnValue;

            int ret = 0;

            cmd.Parameters.Add(codAP);
            cmd.Parameters.Add(dir);
            cmd.Parameters.Add(impLlegada);
            cmd.Parameters.Add(impPartida);
            cmd.Parameters.Add(nomAP);
            cmd.Parameters.Add(codCiu);
            cmd.Parameters.Add(retorno);

            try
            {
                oConexion.Open();
                cmd.ExecuteNonQuery();
                ret = (int)cmd.Parameters["@retorno"].Value;
                if (ret == -1)
                    throw new Exception("Error al verificar datos del aeropuerto");
                if (ret == -2)
                    throw new Exception("Error: La ciudad no existe");

                else if (ret != 1)
                    throw new Exception("Hubo un error inesperado en la modificación del aeropuerto");
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


        //Eliminar Aeropuerto
        public void EliminarAeropuerto(Aeropuerto pAeropuerto, Empleado pEmp)
        {
            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pEmp));
            SqlCommand cmd = new SqlCommand("sp_EliminarAeropuerto", oConexion);
            cmd.CommandType = CommandType.StoredProcedure;

            SqlParameter codAP = new SqlParameter("@CodigoAP", pAeropuerto.CodigoAP);
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
                    throw new Exception("Error al verificar datos de aeropuerto");
                else if (ret != 1)
                    throw new Exception("Hubo un error inesperado en la eliminacion del aeropuerto");
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


        //Listar Aeropuertos
        public List<Aeropuerto> ListarAeropuertos(Empleado pEmp)
        {
            List<Aeropuerto> listaAeropuerto = new List<Aeropuerto>();
            string codigoAP;
            int impLlegada;
            int impPartida;
            string nombreAP;
            string direccion;
            Ciudad ciudad;

            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pEmp));
            SqlCommand oComando = new SqlCommand("listarAeropuerto", oConexion);
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
                        codigoAP = (string)oReader["CodigoAP"];
                        impLlegada = (int)oReader["ImpLlegada"];
                        impPartida = (int)oReader["ImpPartida"];
                        nombreAP = (string)oReader["NombreAP"];
                        direccion = (string)oReader["Direccion"];
                        ciudad = PersistenciaCiudad.GetInstancia().BuscarCiudad((string)oReader["CodigoCiudad"], pEmp);

                        Aeropuerto unAeropuerto = new Aeropuerto(codigoAP, impLlegada, impPartida, nombreAP, direccion, ciudad);
                        listaAeropuerto.Add(unAeropuerto);
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
            return listaAeropuerto;
        }


    }
}
