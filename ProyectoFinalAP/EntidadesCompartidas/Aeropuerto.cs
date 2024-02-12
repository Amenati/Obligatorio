using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
//-----------------------------------------------
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;


namespace EntidadesCompartidas
{
    public class Aeropuerto //OK
    {
        //Atributos
        private string codigoAP;
        private int impLlegada;
        private int impPartida;
        private string nombreAP;
        private string direccion;
        private string codigoCiudad;

        //Propiedad publico para el objeto ciudad

        [Required(ErrorMessage = "Ingrese la ciudad")]
        [DisplayName("Ciudad")]
        public string CodigoCiudad
        {
            get
            {
                return codigoCiudad;
            }

            set
            {
                codigoCiudad = value;
            }
        }

        //Objeto real
        private Ciudad ciudad;

        [Required]
        //revisar la clase lineas
        //Para que no se cree el objeto vacio en la vista de aeropuerto
        //hacer lo mismo con todas las clases que tengan objetos adentro
        //Hacer un atributo publico para que lo cargue la vista.
        //Porque una vista solo puede manejar un solo concepto.
        public Ciudad Ciudad
        {
            get
            {
                return ciudad;
            }

            set
            {
                ciudad = value;
            }
        }

        //Propiedades (SIN codigo defensivo por usar MVC)
        [Required(ErrorMessage = "Ingrese el codigo del aeropuerto")]
        [DisplayName("Codigo Aeropuerto")]
        public string CodigoAP
        {
            get
            {
                return codigoAP;
            }

            set
            {
                codigoAP = value;
            }
        }


        [Required(ErrorMessage = "Ingrese el valor del impuesto")]
        [DisplayName("Impuesto llegada")]
        public int ImpLlegada
        {
            get
            {
                return impLlegada;
            }

            set
            {
                impLlegada = value;
            }
        }

        [Required(ErrorMessage = "Ingrese el valor del impuesto")]
        [DisplayName("Impuesto partida")]
        public int ImpPartida
        {
            get
            {
                return impPartida;
            }

            set
            {
                impPartida = value;
            }
        }

        [Required(ErrorMessage = "Ingrese el nombre del aeropuerto")]
        [DisplayName("Nombre aeropuerto")]
        public String NombreAP
        {
            get
            {
                return nombreAP;
            }

            set
            {
                nombreAP = value;
            }
        }


        [Required(ErrorMessage = "Ingrese la direccion")]
        public String Direccion
        {
            get
            {
                return direccion;
            }

            set
            {
                direccion = value;
            }
        }

       
        //Constructor completo y por defecto
        public Aeropuerto()
        { }

        public Aeropuerto(string codigoAP, int impLlegada, int impPartida, string nombreAP, string direccion, Ciudad ciudad)
        {
            CodigoAP = codigoAP;
            ImpLlegada = impLlegada;
            ImpPartida = impPartida;
            NombreAP = nombreAP;
            Direccion = direccion;
            Ciudad = ciudad;
        }

        public void Validar()
        {
 
             if(string.IsNullOrEmpty(CodigoAP))
                throw new Exception("Debe especificar el codigo de aeropuerto.");

            if (!Regex.IsMatch(this.CodigoAP, @"^[A-Za-z]{3}$"))
                throw new Exception("Error: El codigo de aeropuerto debe ser de 3 letras");

            if (ImpLlegada <= 0)
                throw new Exception("El impuesto de llegada debe ser igual o mayor a 0.");

            if (ImpPartida <= 0)
                throw new Exception("El impuesto de partida debe ser igual o mayor a 0.");


            if (string.IsNullOrEmpty(NombreAP)) 
                    throw new Exception("Debe especificar el nombre del aeropuerto.");
  
            if(NombreAP.Trim().Length>30)
                throw new Exception("Error: El nombre del aeropuerto debe estar formado con un maximo de 30 letras.");


            if(string.IsNullOrEmpty(Direccion))
                throw new Exception("Debe especificar la direccion del aeropuerto.");

            if (Direccion.Trim().Length > 30)
                throw new Exception("Error: La direccion del aeropuerto debe estar formado con un maximo de 30 letras.");

            if (Ciudad == null)
                throw new Exception("Debe especificar el codigo de ciudad.");
        }

    }
}
