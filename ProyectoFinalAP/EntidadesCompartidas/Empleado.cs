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
   public class Empleado //OK
    {
        private string usuLog;
        private string nombreUsu;
        private string usuPass;
        private string cargo;


        //Atributos

        [DisplayName("Nombre de usuario")]
        [Required]
        public string UsuLog
        {
            get
            {
                return usuLog;
            }

            set
            {
                usuLog = value;
            }
        }

        [DisplayName("Nombre completo empleado")]
        [Required]
        public string NombreUsu
        {
            get
            {
                return nombreUsu;
            }

            set
            {
                nombreUsu = value;
            }
        }

        [DisplayName("Password")]
        [Required]
        public string UsuPass
        {
            get
            {
                return usuPass;
            }

            set
            {
                usuPass = value;
            }
        }


        [Required]
        public string Cargo
        {
            get
            {
                return cargo;
            }

            set
            {
                cargo = value;
            }
        }

        //Constructor

        public Empleado(string usuLog, string nombreUsu, string usuPass, string cargo)
        {
            this.usuLog = usuLog;
            this.nombreUsu = nombreUsu;
            this.usuPass = usuPass;
            this.cargo = cargo;
        }

        public Empleado() { }

        //Validar
        public void ValidarEmpleado()
        {
            if (string.IsNullOrEmpty(this.NombreUsu))
                throw new Exception("El nombre no puede estar vacio");
            if (string.IsNullOrEmpty(this.UsuLog))
                throw new Exception("El nombre de usuario no puede estar vacio");
            if (string.IsNullOrEmpty(this.UsuPass))
                throw new Exception("La contraseña no puede estar vacia");
            if (string.IsNullOrEmpty(this.Cargo))
                throw new Exception("El cargo no puede estar vacio");
            //Validar Cargo= admin, vendedor, gerente
        }


    }
}
