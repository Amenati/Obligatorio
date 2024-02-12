using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
//-------------------------------------------
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;

namespace EntidadesCompartidas
{
    public class Vuelo //OK
    {
        //Atributos
        private string codigoVuelo;
        private DateTime fechaPartida;
        private DateTime fechaLlegada;
        private int cantAsientos;
        private int precioPasaje;
        private string codigoAPOrigen;
        private string codigoAPDestino;

        //Atributos/Propiedades publicas para manejo de la Vista
        [Required(ErrorMessage ="Ingrese aeropuerto de origen")]
        public string CodigoAPOrigen
        {
            get
            {
                return codigoAPOrigen;
            }

            set
            {
                codigoAPOrigen = value;
            }
        }

        [Required(ErrorMessage = "Ingrese numero de pasaporte")]
        public string CodigoAPDestino
        {
            get
            {
                return codigoAPDestino;
            }

            set
            {
                codigoAPDestino = value;
            }
        }

        //Atributos de asociacion
        Aeropuerto aeropOrigen;
        Aeropuerto aeropDestino;

        //Propiedades (SIN codigo defensivo por usar MVC)

        [Required]
        public string CodigoVuelo
        {
            get
            {
                return codigoVuelo;
            }

            set
            {
                codigoVuelo = value;
            }
        }


       
        [DisplayName("Fecha de partida")]
        [DataType(DataType.DateTime)]
        public DateTime FechaPartida
        {
            get
            {
                return fechaPartida;
            }

            set
            {
                fechaPartida = value;
            }
        }


        [DisplayName("Fecha de arrivo")]
        [DataType(DataType.DateTime)]
        public DateTime FechaLlegada
        {
            get
            {
                return fechaLlegada;
            }

            set
            {
                fechaLlegada = value;
            }
        }

        [Required]
        [DisplayName("Cantidad de asientos")]
        public int CantAsientos
        {
            get
            {
                return cantAsientos;
            }

            set
            {
                cantAsientos = value;
            }
        }

        [Required]
        [DisplayName("Precio pasaje")]
        public int PrecioPasaje
        {
            get
            {
                return precioPasaje;
            }

            set
            {
                precioPasaje = value;
            }
        }


        [DisplayName("Aeropuerto origen")]
        public Aeropuerto AeropOrigen
        {
            get
            {
                return aeropOrigen;
            }

            set
            {
                aeropOrigen = value;
            }
        }

        [DisplayName("Aeropuerto destino")]
        public Aeropuerto AeropDestino
        {
            get
            {
                return aeropDestino;
            }

            set
            {
                aeropDestino = value;
            }
        }


        //Constructor completo y por defecto

        public Vuelo()
        { }

        public Vuelo(string codigoVuelo, DateTime fechaPartida, DateTime fechaLlegada, int cantAsientos, int precioPasaje, Aeropuerto aeropOrigen, Aeropuerto aeropDestino)
        {
            CodigoVuelo = codigoVuelo;
            FechaPartida = fechaPartida;
            FechaLlegada = fechaLlegada;
            CantAsientos = cantAsientos;
            PrecioPasaje = precioPasaje;
            AeropOrigen = aeropOrigen;
            AeropDestino = aeropDestino;
        }

        public void Validar()
         {
            if (!Regex.IsMatch(this.CodigoVuelo, @"^[0-9]{12}[A-Za-z]{3}$"))
                throw new Exception("Error: Codigo Vuelo debe estar formado por 12 digitos y 3 letras");      
            if (FechaPartida >=FechaLlegada)
                throw new Exception("La fecha de llegada debe ser posterior a la fecha de partida ");
            if (CantAsientos < 100 || CantAsientos >300)
                throw new Exception("Error: Cantidad de asientos debe ser entre 100 y 300 ");
            if (PrecioPasaje < 0)
                throw new Exception("El precio debe ser mayor a cero");
            if(AeropDestino==null)
                throw new Exception("Debe especificar aeropuerto de destino");
            if (AeropOrigen == null)
                throw new Exception("Debe especificar aeropuerto de origen");
            if (AeropDestino.CodigoAP == AeropOrigen.CodigoAP)
                throw new Exception("Error: Aeropuerto de origen no puede ser igual a Aeropuerto destino");
        }

        

    }
}
