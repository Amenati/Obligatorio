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
    internal class PersistenciaCiudad : IPersistenciaCiudad
    {
        //SINGLETON
        private static PersistenciaCiudad instancia; //atributo de clase
        private PersistenciaCiudad() { } //constructor privado

        public static PersistenciaCiudad GetInstancia()
        {
            if (instancia == null)
                instancia = new PersistenciaCiudad();

            return instancia;
        }
        //FIN SINGLETON

        public void AgregarCiudad(Ciudad ciudad,Empleado pLogueo)
        {
            SqlConnection cnn = new SqlConnection(Conexion.Cnn(pLogueo));
            SqlCommand oComando = new SqlCommand("AgregarCiudad", cnn);
            oComando.CommandType = CommandType.StoredProcedure;
            oComando.Parameters.AddWithValue("@codigoCiudad", ciudad.CodigoCiudad);
            oComando.Parameters.AddWithValue("@nomCiudad", ciudad.NombreCiudad);
            oComando.Parameters.AddWithValue("@pais", ciudad.Pais);
            SqlParameter oRetorno = new SqlParameter("@Retorno", SqlDbType.Int);
            oRetorno.Direction = ParameterDirection.ReturnValue;
            oComando.Parameters.Add(oRetorno);

            try
            {
                cnn.Open();
                oComando.ExecuteNonQuery();
                if ((int)oRetorno.Value == -1)
                    throw new Exception("Ya existe la ciudad");
                if ((int)oRetorno.Value == -2)
                    throw new Exception("Error inesperado");
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

        internal Ciudad BuscarCiudad(string pCodigoCiudad, Empleado pLogueo) //buscar todos
        {
            Ciudad ciudad = new Ciudad();

            SqlConnection cnn = new SqlConnection(Conexion.Cnn(pLogueo));
            SqlCommand comando = new SqlCommand("BuscarCiudad", cnn);
            comando.CommandType = CommandType.StoredProcedure;
            comando.Parameters.AddWithValue("@codigoCiudad", pCodigoCiudad);

            SqlDataReader oReader;

            try
            {
                cnn.Open();
                oReader = comando.ExecuteReader();

                if (oReader.HasRows)
                {
                    if (oReader.Read())
                    {
                        ciudad = new Ciudad(pCodigoCiudad, (string)oReader["NomCiudad"],
                            (string)oReader["Pais"]);
                    }
                }
                oReader.Close();
            }
            catch (Exception)
            {

                throw;
            }
            finally
            {
                cnn.Close();
            }

            return ciudad;
        }


        public Ciudad BuscarCiudadActivo(string pCodigoCiudad, Empleado pLogueo) //buscar activo
        {
            Ciudad ciudad = new Ciudad();

            SqlConnection cnn = new SqlConnection(Conexion.Cnn(pLogueo));
            SqlCommand comando = new SqlCommand("BuscarCiudadActiva", cnn);
            comando.CommandType = CommandType.StoredProcedure;
            comando.Parameters.AddWithValue("@codigoCiudad", pCodigoCiudad);

            SqlDataReader oReader;

            try
            {
                cnn.Open();
                oReader = comando.ExecuteReader();
                if (oReader.HasRows)
                {
                    if (oReader.Read())
                    {
                        ciudad = new Ciudad(pCodigoCiudad, (string)oReader["NomCiudad"],
                            (string)oReader["Pais"]);
                    }
                }
                oReader.Close();
            }
            catch (Exception)
            {

                throw;
            }
            finally
            {
                cnn.Close();
            }

            return ciudad;
        }


        public void ModificarCiudad(Ciudad ciudad, Empleado pLogueo)
        {
            SqlConnection cnn = new SqlConnection(Conexion.Cnn(pLogueo));


            SqlCommand oComando = new SqlCommand("ModificarCiudad", cnn);
            oComando.CommandType = CommandType.StoredProcedure;
            oComando.Parameters.AddWithValue("@codigoCiudad", ciudad.CodigoCiudad);
            oComando.Parameters.AddWithValue("@nomCiudad", ciudad.NombreCiudad);
            oComando.Parameters.AddWithValue("@pais", ciudad.Pais);
            SqlParameter oRetorno = new SqlParameter("@Retorno", SqlDbType.Int);
            oRetorno.Direction = ParameterDirection.ReturnValue;
            oComando.Parameters.Add(oRetorno);

            try
            {
                cnn.Open();
                oComando.ExecuteNonQuery();
                if ((int)oRetorno.Value == -1)
                    throw new Exception("Error: La Ciudad no existe");
                else if ((int)oRetorno.Value == -2)
                    throw new Exception("Error inseperado");
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

        public void EliminarCiudad(Ciudad ciudad, Empleado pLogueo)
        {
            SqlConnection cnn = new SqlConnection(Conexion.Cnn(pLogueo));


            SqlCommand oComando = new SqlCommand("EliminarCiudad", cnn);
            oComando.CommandType = CommandType.StoredProcedure;
            oComando.Parameters.AddWithValue("@codigoCiudad", ciudad.CodigoCiudad);
            SqlParameter oRetorno = new SqlParameter("@Retorno", SqlDbType.Int);
            oRetorno.Direction = ParameterDirection.ReturnValue;
            oComando.Parameters.Add(oRetorno);

            try
            {
                cnn.Open();
                oComando.ExecuteNonQuery();
                if ((int)oRetorno.Value == -1)
                    throw new Exception("Error: La ciudad no existe");
                else if ((int)oRetorno.Value == -2)
                    throw new Exception("Error inesperado");
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

        //Listar Ciudades
        public List<Ciudad> ListarCiudades(Empleado pEmp)
        {
            List<Ciudad> listaCiudades = new List<Ciudad>();
            string codigoCiudad;
            string nombreCiudad;
            string pais;

            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pEmp));
            SqlCommand oComando = new SqlCommand("ListadoCiudades", oConexion);
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
                        codigoCiudad = (string)oReader["CodigoCiudad"];
                        nombreCiudad = (string)oReader["NomCiudad"];
                        pais = (string)oReader["Pais"];

                        Ciudad unaCiudad = new Ciudad(codigoCiudad, nombreCiudad, pais);
                        listaCiudades.Add(unaCiudad);
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
            return listaCiudades;
        }
    }
}
