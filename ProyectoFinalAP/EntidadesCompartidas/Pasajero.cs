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
  public  class Pasajero //Finalizado
    {

        //Atributos
        int nroAsiento;
        //Atributos de asociacion
        Cliente cliente;


        [DisplayName("N° Asiento")]
        [Required]
        public int NroAsiento
        {
            get
            {
                return nroAsiento;
            }

            set
            {
                nroAsiento = value;
            }
        }

        [Required]
        public Cliente Cliente
        {
            get
            {
                return cliente;
            }

            set
            {
                cliente = value;
            }
        }

   

        //Constructores

        public Pasajero() { }
        public Pasajero(int nroAsiento, Cliente cliente)
        {
            this.nroAsiento = nroAsiento;
            this.cliente = cliente;
   
        }

        //Validar
        public void Validar()
        {
            if (NroAsiento< 1 || NroAsiento>300)
                throw new Exception("Error: Numero de asiento de asientos debe ser entre 1 y 300 ");
            if (Cliente == null)
                throw new Exception("Debe especificar el cliente");
           
        }
        

    }
}
