using System;
using System.Collections.Generic;
using System.Text;

namespace PSServiceBus.Exceptions
{
    public class NonExistentEntityException : Exception
    {
        public NonExistentEntityException() : base() { }

        public NonExistentEntityException(string message) : base(message) { }
    }
}
