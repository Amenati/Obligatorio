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
    public class Cliente //ok
    {

        //Atributos
        private string numPasaporte;
        private string nombreCliente;
        private string clientPass;
        private int numTarjeta;


        //Propiedades (SIN codigo defensivo por usar MVC)
        [Required]
        [DisplayName("Nro. Pasporte")]
        public string NumPasaporte
        {
            get
            {
                return numPasaporte;
            }

            set
            {
                numPasaporte = value;
            }
        }


        [Required]
        [DisplayName("Nombre cliente")]
        public String NombreCliente
        {
            get
            {
                return nombreCliente;
            }

            set
            {
                nombreCliente = value;
            }
        }


        [Required]
        [DisplayName("Password")]
        public String ClientPass
        {
            get
            {
                return clientPass;
            }

            set
            {
                clientPass = value;
            }
        }


        [Required]
        [DisplayName("Nro. Tarjeta")]
        public int NumTarjeta
        {
            get
            {
                return numTarjeta;
            }

            set
            {
                numTarjeta = value;
            }
        }



        //Constructor completo y por defecto
        public Cliente()
        { }

        public Cliente(string numPasaporte, string nombreCliente, string clientPass, int numTarjeta)
        {
            NumPasaporte = numPasaporte;
            NombreCliente = nombreCliente;
            ClientPass = clientPass;
            NumTarjeta = numTarjeta;
        }

        public void Validar()
        {
     
            if(string.IsNullOrEmpty(NumPasaporte))
                throw new Exception("Debe especificar el numero de pasaporte.");

      
            if(NumPasaporte.Trim().Length>10)
                throw new Exception("Error: El numero de pasaporte del cliente debe estar formada por maximo 10 digitos.");

   
            if(string.IsNullOrEmpty(ClientPass))
                throw new Exception("Debe especificar la contraseña.");

        

            if (ClientPass.Trim().Length > 10)
                throw new Exception("Error: el password debe contener maximo 8 digitos.");


       
            if (string.IsNullOrEmpty(NombreCliente))
                throw new Exception("Debe especificar el nombre del cliente.");

   
            if (NombreCliente.Trim().Length > 20)
                throw new Exception("Error: el nombre del cliente debe contener maximo 20 digitos.");

            if (!Regex.IsMatch(Convert.ToString(this.NumTarjeta), @"^[0-9]{9}$"))
                throw new Exception("Error: numero de tarjeta maximo 9 digitos.");
        }

    }
}
