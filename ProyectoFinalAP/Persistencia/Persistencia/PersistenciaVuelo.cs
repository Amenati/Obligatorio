using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
//--------------------------------
using System.Data.SqlClient;
using System.Data;
using EntidadesCompartidas;

namespace Persistencia //OK
{
    internal class PersistenciaVuelo:IPersistenciaVuelo
    {

        //SINGLETON
        private static PersistenciaVuelo instancia; //atributo de clase
        private PersistenciaVuelo() { } //constructor privado

        public static PersistenciaVuelo GetInstancia()
        {
            if (instancia == null)
                instancia = new PersistenciaVuelo();

            return instancia;
        }
        //FIN SINGLETON

        public void AltaVuelo(Vuelo unVuelo, Empleado pLogueo)
        {
            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pLogueo));

            SqlCommand oComando = new SqlCommand("AltaVuelo", oConexion);
            oComando.CommandType = CommandType.StoredProcedure;
            oComando.Parameters.AddWithValue("@codigoVuelo", unVuelo.CodigoVuelo);
            oComando.Parameters.AddWithValue("@fechaPartida", unVuelo.FechaPartida);
            oComando.Parameters.AddWithValue("@fechaLlegada", unVuelo.FechaLlegada);
            oComando.Parameters.AddWithValue("@cantAsientos", unVuelo.CantAsientos);
            oComando.Parameters.AddWithValue("@precioPasaje", unVuelo.PrecioPasaje);
            oComando.Parameters.AddWithValue("@codigoAeropOrigen", unVuelo.AeropOrigen.CodigoAP);
            oComando.Parameters.AddWithValue("@codigoAeropDestino", unVuelo.AeropDestino.CodigoAP);

            SqlParameter oRetorno = new SqlParameter("@Retorno", SqlDbType.Int);
            oRetorno.Direction = ParameterDirection.ReturnValue;
            oComando.Parameters.Add(oRetorno);

            try
            {
                oConexion.Open();
                oComando.ExecuteNonQuery();

                int retorno = Convert.ToInt32(oRetorno.Value);

                if (retorno == -1)
                    throw new Exception("Error: el vuelo ya existe");
                if (retorno == -2)
                    throw new Exception("Error: Aeropuesrto de destino no existe");
                if (retorno == -3)
                    throw new Exception("Error: Aeropuesrto de origen no existe");
                if (retorno == -4)
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

        public List<Vuelo> ListarVuelos(Empleado pLogueo)
        {
        List<Vuelo> listaVuelos = new List<Vuelo>();
        string codigoVuelo;
        DateTime fechaPartida;
        DateTime fechaLlegada;
        int cantAsientos;
        int precioPasaje;
        Aeropuerto aeropOrigen;
        Aeropuerto aeropDestino;


            SqlConnection oConexion = new SqlConnection(Conexion.Cnn(pLogueo));
            SqlCommand oComando = new SqlCommand("ListadoVuelos", oConexion);
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
                        codigoVuelo = (string)oReader["CodigoVuelo"];
                        fechaPartida = (DateTime)oReader["FechaPartida"];
                        fechaLlegada = (DateTime)oReader["FechaLlegada"];
                        cantAsientos = (int)oReader["CantAsientos"];
                        precioPasaje = (int)oReader["PrecioPasaje"];
                        aeropOrigen = PersistenciaAeropuerto.GetInstancia().BuscarAeropuerto((string)oReader["CodigoAeropOrigen"], pLogueo);
                        aeropDestino = PersistenciaAeropuerto.GetInstancia().BuscarAeropuerto((string)oReader["CodigoAeropDestino"], pLogueo);

                        Vuelo unVuelo = new Vuelo(codigoVuelo, fechaPartida, fechaLlegada, cantAsientos, precioPasaje, aeropOrigen, aeropDestino);
                        listaVuelos.Add(unVuelo);
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

            return listaVuelos;

        }

    }
}
