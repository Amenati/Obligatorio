using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
//-------------------------------------------
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;

namespace EntidadesCompartidas //finalizado
{
    public class Venta
    {

        //Atributos
        private int nroVenta;
        private DateTime fechaCompra;
        private int monto;

        //Atributos de asociacion
        private Empleado empleado;
        private Vuelo vuelo;
        private Cliente pagador;
        private List<Pasaje> pasajes;
        //Lista de pasajeros es como haciamos la factura



        //Propiedades (sin codigo defensivo)
        public int NroVenta //(autogenerado)
        {
            get
            {
                return nroVenta;
            }

            set
            {
                nroVenta = value;
            }
        }

        [DisplayName("Fecha de compra")]
        [DataType(DataType.DateTime)]
        public DateTime FechaCompra //(default)
        {
            get
            {
                return fechaCompra;
            }

            set
            {
                fechaCompra = value;
            }
        }

        [Required]
        public int Monto
        {
            get
            {
                return monto;
            }

            set
            {
                monto = value;
            }
        }

  
        public Empleado Empleado
        {
            get
            {
                return empleado;
            }

            set
            {
                empleado = value;
            }
        }

        //Atributo/Propiedad VUELO para manejo en la Vista
        private string codigoVuelo;

        [Required(ErrorMessage = "Ingrese el codigo del vuelo")]
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

        //Atributo/Propiedad CLIENTE para manejo en la Vista
        private string nroPasaporte;

        [Required(ErrorMessage = "Ingrese el codigo del vuelo")]
        public string NroPasaporte
        {
            get
            {
                return nroPasaporte;
            }

            set
            {
                nroPasaporte = value;
            }
        }

        public Vuelo Vuelo
        {
            get
            {
                return vuelo;
            }

            set
            {
                vuelo = value;
            }
        }

  
        [DisplayName("Comprador")]
        public Cliente Pagador
        {
            get
            {
                return pagador;
            }

            set
            {
                pagador = value;
            }
        }


        public List<Pasaje> Pasajes
        {
            get
            {
                return pasajes;
            }

            set
            {
                pasajes = value;
            }
        }

        //Constructores
        public Venta(int nroVenta, DateTime fechaCompra, int monto, Empleado empleado, Vuelo vuelo, Cliente pagador, List<Pasaje> pasajes)
        {
            this.nroVenta = nroVenta;
            this.fechaCompra = fechaCompra;
            this.monto = monto;
            this.empleado = empleado;
            this.vuelo = vuelo;
            this.pagador = pagador;
            this.pasajes = pasajes;
        }

        public Venta()
        { }

        //Validar
        public void Validar()
        {
           //no valido fecha por ser default sistema
            if (Monto < 100)
                throw new Exception("Monto debe ser positivo ");
            if (Empleado == null)
                throw new Exception("Debe especificar el empleado");
            if (Vuelo == null)
                throw new Exception("Debe especificar el vuelo");
            if (Pagador == null)
                throw new Exception("Debe especificar el comprador");
            if (Pasajes == null)
                throw new Exception("Debe especificar la lista de pasajeros");
            if (Pasajes.Count ==0)
                throw new Exception("Debe especificar la lista de pasajeros");

        }




    }
}
