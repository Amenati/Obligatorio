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
    public class Ciudad //OK
    {
        //Atributos

        private string codigoCiudad;
        private string nombreCiudad;
        private string pais;

        //Propiedades


        [Required]
        [DisplayName("Codigo Ciudad")]
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

        [Required]
        [DisplayName("Nombre Ciudad")]
        public string NombreCiudad
        {
            get
            {
                return nombreCiudad;
            }

            set
            {
                nombreCiudad = value;
            }
        }

        [Required]
        public string Pais
        {
            get
            {
                return pais;
            }

            set
            {
                pais = value;
            }
        }

        //Constructores

        public Ciudad(string codigoCiudad, string nombreCiudad, string pais)
        {
            this.codigoCiudad = codigoCiudad;
            this.nombreCiudad = nombreCiudad;
            this.pais = pais;
        }

        public Ciudad() { }


        public void Validar()
        {
            if (string.IsNullOrEmpty(NombreCiudad))
                throw new Exception("El nombre no puede estar vacio");

            if (NombreCiudad.Trim().Length > 40)
                throw new Exception("Error: El nombre dela ciudad debe estar formado por un maximo de 40 caracteres.");

            if (string.IsNullOrEmpty(Pais))
                throw new Exception("El pais no puede estar vacio");

            if (Pais.Trim().Length > 40)
                throw new Exception("Error: El nombre del pais debe estar formado por un maximo de 40 caracteres.");

            if (string.IsNullOrEmpty(CodigoCiudad))
                throw new Exception("El pais no puede estar vacio");

            if (!Regex.IsMatch(CodigoCiudad, @"^[A-Za-z]{6}$"))
                throw new Exception("Error: El codigo de la ciudad debe ser de 6 letras");

        }

    }
}
