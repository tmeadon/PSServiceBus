using System.Collections.Generic;
using System.Management.Automation;
using Microsoft.Azure.ServiceBus.Management;
using PSServiceBus.Outputs;
using PSServiceBus.Helpers;

namespace PSServiceBus.Cmdlets
{
    /// <summary>
    /// <para type="synopsis">Tests whether a connection string is valid or not.</para>
    /// <para type="description">Tests whether a connection string is valid or not.</para>
    /// </summary>
    /// <example>
    /// <code>Test-SbConnectionString -NamespaceConnectionString $namespaceConnectionString</code>
    /// <para>This tests whether $namespaceConnectionString is valid or not.</para>
    /// </example>
    [Cmdlet(VerbsDiagnostic.Test, "SbConnectionString")]
    [OutputType(typeof(bool))]
    public class TestSbConnectionString : Cmdlet
    {

        /// <summary>
        /// <para type="description">Connection string to test.</para>
        /// </summary>
        [Parameter(Mandatory = true)]
        public string NamespaceConnectionString { get; set; }

        /// <summary>
        /// Main cmdlet method.
        /// </summary>
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