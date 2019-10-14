using System.Collections.Generic;
using System.Management.Automation;
using Microsoft.Azure.ServiceBus.Management;
using PSServiceBus.Outputs;
using PSServiceBus.Helpers;

namespace PSServiceBus.Cmdlets
{
    [Cmdlet(VerbsDiagnostic.Test, "SbConnectionString")]
    [OutputType(typeof(bool))]
    public class TestSbConnectionString : Cmdlet
    {
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        protected override void ProcessRecord()
        {
            try
            {
                SbManager sbManager = new SbManager(NamespaceConnectionString);

                if (sbManager != null)
                {
                    WriteObject(true);
                }
                else
                {
                    WriteObject(false);
                }
            }
            catch
            {
                WriteObject(false);
            }
        }
    }
}